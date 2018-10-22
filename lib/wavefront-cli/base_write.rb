require 'wavefront-sdk/support/mixins'
require_relative 'base'

module WavefrontCli
  #
  # Send points to a proxy.
  #
  class BaseWrite < Base
    attr_reader :fmt
    include Wavefront::Mixins

    # rubocop:disable Metrics/AbcSize
    def do_point
      p = { path:  options[:'<metric>'],
            value: options[:'<value>'].delete('\\').to_f,
            tags:  tags_to_hash(options[:tag]) }

      p[:source] = options[:host] if options[:host]
      p[:ts] = parse_time(options[:time]) if options[:time]
      send_point(p)
    end
    # rubocop:enable Metrics/AbcSize

    def send_point(point)
      call_write(point)
    rescue Wavefront::Exception::InvalidEndpoint
      abort format("Could not connect to proxy '%s:%s'.",
                   options[:proxy], options[:port])
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
        data = process_input_file(load_data(Pathname.new(file)).split("\n"))
        call_write(data)
      end
    end

    def process_input_file(data)
      data.each_with_object([]) do |l, a|
        begin
          a.<< process_line(l)
        rescue WavefrontCli::Exception::UnparseableInput => e
          puts "Bad input. #{e.message}."
          next
        end
      end
    end

    # A wrapper which lets us send normal points, deltas, or
    # distributions
    #
    def call_write(data, openclose = true)
      if options[:delta]
        wf.write_delta(data, openclose)
      else
        wf.write(data, openclose)
      end
    end

    # Read from standard in and stream points through an open
    # socket. If the user hits ctrl-c, close the socket and exit
    # politely.
    #
    def read_stdin
      open_connection
      STDIN.each_line { |l| call_write(process_line(l.strip), false) }
      close_connection
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
      if fmt.include?('v')
        v = chunks[fmt.index('v')]
        v.to_f
      else
        raw = chunks[fmt.index('d')].split(',')
        xpanded = expand_dist(raw)
        wf.mk_distribution(xpanded)
      end
    end

    # We will let users write a distribution as '1 1 1' or '3x1' or
    # even a mix of the two
    #
    def expand_dist(dist)
      dist.map do |v|
        if v.is_a?(String) && v.include?('x')
          x, val = v.split('x', 2)
          Array.new(x.to_i, val.to_f)
        else
          v.to_f
        end
      end.flatten
    end

    # Find and return the source in a chunked line of input.
    #
    # @param chunks [Array] a chunked line of input from #process_line
    # @return [Float] the timestamp, if it is there, or the current
    #   UTC time if it is not.
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
      options[:metric] ? [options[:metric], m].join('.') : m
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
      chunks[fmt.index('s')]
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
    # @raise WavefrontCli::Exception::UnparseableInput if the line
    #   doesn't look right
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def process_line(line)
      return true if line.empty?
      chunks = line.split(/\s+/, fmt.length)
      enough_fields?(line) # can raise exception

      begin
        point = { path:  extract_path(chunks),
                  tags:  line_tags(chunks),
                  value: extract_value(chunks) }

        point[:ts]       = extract_ts(chunks)        if fmt.include?('t')
        point[:source]   = extract_source(chunks)    if fmt.include?('s')
        point[:interval] = options[:interval] || 'm' if fmt.include?('d')
      rescue TypeError
        raise(WavefrontCli::Exception::UnparseableInput,
              "could not process #{line}")
      end

      point
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

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

    # The format string must contain values. They can be single
    # values or distributions. So we must have 'v' xor 'd'. It must
    # not contain anything other than 'm', 't', 'T', 's', 'd', or
    # 'v', and the 'T', if there, must be at the end. No letter must
    # appear more than once.
    #
    # @param fmt [String] format of input file
    #
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def valid_format?(fmt)
      err = if fmt.include?('v') && fmt.include?('d')
              "'v' and 'd' are mutually exclusive"
            elsif !fmt.include?('v') && !fmt.include?('d')
              "format string must include 'v' or 'd'"
            elsif !fmt.match(/^[dmstTv]+$/)
              'unsupported field in format string'
            elsif !fmt == fmt.split('').uniq.join
              'repeated field in format string'
            elsif fmt.include?('T') && !fmt.end_with?('T')
              "if used, 'T' must come at end of format string"
            end

      return true if err.nil?

      raise(WavefrontCli::Exception::UnparseableInput, err)
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

    # Make sure we have the right number of columns, according to
    # the format string. We want to take every precaution we can to
    # stop users accidentally polluting their metric namespace with
    # junk.
    #
    # If the format string says we are expecting point tags, we
    # may have more columns than the length of the format string.
    #
    def enough_fields?(line)
      ncols = line.split.length
      return true if fmt.include?('T') && ncols >= fmt.length
      return true if ncols == fmt.length
      raise(WavefrontCli::Exception::UnparseableInput,
            format('Expected %s fields, got %s', fmt.length, ncols))
    end

    # Although the SDK does value checking, we'll add another layer
    # of input checing here.  See if the time looks valid. We'll
    # assume anything before 2000/01/01 or after a year from now is
    # wrong.  Arbitrary, but there has to be a cut-off somewhere.
    #
    def valid_timestamp?(timestamp)
      (timestamp.is_a?(Integer) || timestamp.match(/^\d+$/)) &&
        timestamp.to_i > 946_684_800 &&
        timestamp.to_i < (Time.now.to_i + 31_557_600)
    end

    private

    def setup_fmt(fmt)
      @fmt = fmt.split('')
    end

    def load_data(file)
      IO.read(file)
    rescue StandardError
      raise WavefrontCli::Exception::FileNotFound
    end
  end
end
