require 'wavefront-sdk/mixins'
require_relative './base'

module WavefrontCli
  #
  # Send points to a proxy.
  #
  class Write < Base
    attr_reader :fmt
    include Wavefront::Mixins

    def mk_creds
      { proxy: options[:proxy], port: options[:port] || 2878 }
    end
    def do_point
      p = { path:  options[:'<metric>'],
            value: options[:'<value>'].to_f,
            tags:  tags_to_hash(options[:tag]) }

      p[:source] = options[:host] if options[:host]
      p[:ts] = parse_time(options[:time]) if options[:time]

      begin
        wf.write(p)
      rescue Wavefront::Exception::InvalidEndpoint
        abort 'could not speak to proxy ' \
              "'#{options[:proxy]}:#{options[:port]}'."
      end
    end

    def do_file
      valid_format?(options[:infileformat])
      setup_fmt(options[:infileformat] || 'tmv')
      process_input(options[:'<file>'])
    end

    # Read the input, from a file or from STDIN, and turn each line
    # into Wavefront points.
    #
    def process_input(file)
      if file == '-'
        read_stdin
      else
        data = load_data(Pathname.new(file)).split("\n").map do |l|
          process_line(l)
        end

        wf.write(data)
      end
    end

    # Read from standard in and stream points through an open
    # socket. If the user hits ctrl-c, close the socket and exit
    # politely.
    #
    def read_stdin
      wf.open
      STDIN.each_line { |l| wf.write(process_line(l.strip), false) }
      wf.close
    rescue SystemExit, Interrupt
      puts 'ctrl-c. Exiting.'
      wf.close
      exit 0
    end

    # Find and return the value in a chunked line of input
    #
    # param chunks [Array] a chunked line of input from #process_line
    # return [Float] the value
    # raise TypeError if field does not exist
    # raise Wavefront::Exception::InvalidValue if it's not a value
    #
    def extract_value(chunks)
      v = chunks[fmt.index('v')]
      v.to_f
    end

    # Find and return the source in a chunked line of input.
    #
    # param chunks [Array] a chunked line of input from #process_line
    # return [Float] the timestamp, if it is there, or the current
    #   UTC time if it is not.
    # raise TypeError if field does not exist
    #
    def extract_ts(chunks)
      ts = chunks[fmt.index('t')]
      return parse_time(ts) if valid_timestamp?(ts)
    rescue TypeError
      Time.now.utc.to_i
    end

    def extract_tags(chunks)
      tags_to_hash(chunks.last.split(/\s(?=(?:[^"]|"[^"]*")*$)/))
    end

    # Find and return the metric path in a chunked line of input.
    # The path can be in the data, or passed as an option, or both.
    # If the latter, then we assume the option is a prefix, and
    # concatenate the value in the data.
    #
    # param chunks [Array] a chunked line of input from #process_line
    # return [String] the metric path
    # raise TypeError if field does not exist
    #
    def extract_path(chunks)
      m = chunks[fmt.index('m')]
      return options[:metric] ? [options[:metric], m].join('.') : m
    rescue TypeError
      return options[:metric] if options[:metric]
      raise
    end

    # Find and return the source in a chunked line of input.
    #
    # param chunks [Array] a chunked line of input from #process_line
    # return [String] the source, if it is there, or if not, the
    #   value passed through by -H, or the local hostname.
    #
    def extract_source(chunks)
      return chunks[fmt.index('s')]
    rescue TypeError
      options[:source] || Socket.gethostname
    end

    # Process a line of input, as described by the format string
    # held in @fmt. Produces a hash suitable for the SDK to send on.
    #
    # We let the user define most of the fields, but anything beyond
    # what they define is always assumed to be point tags.  This is
    # because you can have arbitrarily many of those for each point.
    #
    def process_line(l)
      return true if l.empty?
      chunks = l.split(/\s+/, fmt.length)
      raise 'wrong number of fields' unless enough_fields?(l)

      begin
        point = { path:  extract_path(chunks),
                  value: extract_value(chunks) }
        point[:ts] = extract_ts(chunks) if fmt.include?('t')
        point[:source] = extract_source(chunks) if fmt.include?('s')
        point[:tags] = line_tags(chunks)
      rescue TypeError
        raise "could not process #{l}"
      end

      point
    end

    # We can get tags from the file, from the -T option, or both.
    # Merge them, making the -T win if there is a collision.
    #
    def line_tags(chunks)
      file_tags = fmt.last == 'T' ? extract_tags(chunks) : {}
      opt_tags = tags_to_hash(options[:tag])
      file_tags.merge(opt_tags)
    end

    # Takes an array of key=value tags (as produced by docopt) and
    # turns it into a hash of key: value tags.  Anything not of the
    # form key=val is dropped.  If key or value are quoted, we
    # remove the quotes.
    #
    # @param tags [Array]
    # return Hash
    #
    def tags_to_hash(tags)
      return nil unless tags

      [tags].flatten.each_with_object({}) do |t, ret|
        k, v = t.split('=', 2)
        k.gsub!(/^["']|["']$/, '')
        ret[k] = v.to_s.gsub(/^["']|["']$/, '') if v
      end
    end

    # The format string must contain a 'v'. It must not contain
    # anything other than 'm', 't', 'T', 's', or 'v', and the 'T',
    # if there, must be at the end. No letter must appear more than
    # once.
    #
    # @param fmt [String] format of input file
    #
    def valid_format?(fmt)
      if fmt.include?('v') && fmt.match(/^[mstv]+T?$/) &&
         fmt == fmt.split('').uniq.join
        return true
      end

      raise 'Invalid format string.'
    end

    # Make sure we have the right number of columns, according to
    # the format string. We want to take every precaution we can to
    # stop users accidentally polluting their metric namespace with
    # junk.
    #
    # If the format string says we are expecting point tags, we
    # may have more columns than the length of the format string.
    #
    def enough_fields?(l)
      ncols = l.split.length

      if fmt.include?('T')
        return false unless ncols >= fmt.length
      else
        return false unless ncols == fmt.length
      end

      true
    end

    # Although the SDK does value checking, we'll add another layer
    # of input checing here.  See if the time looks valid. We'll
    # assume anything before 2000/01/01 or after a year from now is
    # wrong.  Arbitrary, but there has to be a cut-off somewhere.
    #
    def valid_timestamp?(ts)
      (ts.is_a?(Integer) || ts.match(/^\d+$/)) &&
        ts.to_i > 946_684_800 && ts.to_i < (Time.now.to_i + 31_557_600)
    end

    def validate_opts
      unless options[:metric] || options[:format].include?('m')
        abort "Supply a metric path in the file or with '-m'."
      end

      raise 'Please supply a proxy address.' unless options[:proxy]
    end

    private

    def setup_fmt(fmt)
      @fmt = fmt.split('')
    end

    def load_data(file)
      raise "Cannot open file '#{file}'." unless file.exist?
      IO.read(file)
    end
  end
end
