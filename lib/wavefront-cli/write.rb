# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'

module WavefrontCli
  #
  # Send points via any method supported by the SDK
  #
  class Write < Base
    attr_reader :fmt

    include Wavefront::Mixins
    SPLIT_PATTERN = /\s(?=(?:[^"]|"[^"]*")*$)/

    # rubocop:disable Metrics/AbcSize
    def do_point(value = options[:'<value>'])
      tags = tags_to_hash(options[:tag])

      p = { path: options[:'<metric>'],
            value: sane_value(value) }

      p[:tags] = tags unless tags.empty?
      p[:source] = options[:host] if options[:host]
      p[:ts] = parse_time(options[:time]) if options[:time]
      send_point(p)
    end
    # rubocop:enable Metrics/AbcSize

    def do_file
      valid_format?(options[:infileformat])
      setup_fmt(options[:infileformat] || 'tmv')
      process_input(options[:'<file>'])
    end

    def do_distribution
      send_point(make_distribution_point(tags_to_hash(options[:tag])))
    end

    def do_noise
      loop do
        do_point(random_value(options[:min] || -10, options[:max] || 10))
        sleep(sleep_time)
      end
    end

    def random_value(min, max)
      return min if min == max

      rand(max.to_f - min.to_f) + min.to_f
    end

    def sane_value(value)
      return value if value.is_a?(Numeric)

      raise WavefrontCli::Exception::InvalidValue unless value.is_a?(String)

      value.delete('\\').to_f
    end

    def sleep_time
      options[:interval] ? options[:interval].to_f : 1
    end

    # rubocop:disable Metrics/AbcSize
    def make_distribution_point(tags)
      { path: options[:'<metric>'],
        interval: options[:interval] || 'M',
        tags: tags,
        value: mk_dist }.tap do |p|
        p[:source] = options[:host] if options[:host]
        p[:ts] = parse_time(options[:time]) if options[:time]
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Turn our user's representation of a distribution into one which suits
    # Wavefront. The SDK can do this for us.
    #
    def mk_dist
      xpanded = expand_dist(options[:'<val>'])
      wf.mk_distribution(xpanded.map(&:to_f))
    end

    def extra_options
      if options[:using]
        { writer: options[:using] }
      else
        { writer: :http }
      end
    end

    # I chose to prioritise UI consistency over internal elegance
    # here. The `write` command doesn't follow the age-old
    # assumption that each command maps 1:1 to a similarly named SDK
    # class. Write can use `write` or `distribution`.
    #
    def _sdk_class
      return 'Wavefront::Distribution' if distribution?

      'Wavefront::Write'
    end

    def distribution?
      return true if options[:distribution]

      options[:infileformat]&.include?('d')
    end

    def mk_creds
      { proxy: options[:proxy],
        port: options[:port] || default_port,
        socket: options[:socket],
        endpoint: options[:endpoint],
        agent: "wavefront-cli-#{WF_CLI_VERSION}",
        token: options[:token] }
    end

    def default_port
      distribution? ? 40_000 : 2878
    end

    # The SDK writer plugins validate the credentials they need
    def validate_opts
      validate_opts_file if options[:file]
    end

    def validate_opts_file
      return true if options[:metric] || options[:infileformat]&.include?('m')

      raise(WavefrontCli::Exception::InsufficientData,
            "Supply a metric path in the file or with '-m'.")
    end

    def open_connection
      wf.open
    end

    def close_connection
      wf.close
    end

    def send_point(point)
      call_write(point)
    rescue Wavefront::Exception::InvalidEndpoint
      abort format("Could not connect to proxy '%<proxy>s:%<port>s'.", wf.creds)
    end

    # Read the input, from a file or from STDIN, and turn each line
    # into Wavefront points.
    #
    def process_input(file)
      if file == '-'
        read_stdin
      else
        call_write(
          process_input_file(load_data(Pathname.new(file)).split("\n"))
        )
      end
    end

    # @param data [Array[String]] array of lines
    #
    def process_input_file(data)
      data.each_with_object([]) do |l, a|
        a << process_line(l)
      rescue WavefrontCli::Exception::UnparseableInput => e
        puts "Bad input. #{e.message}."
        next
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
      ret = $stdin.each_line.map do |l|
        call_write(process_line(l.strip), false)
      end
      close_connection
      ret.last
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
      parse_time(ts) if valid_timestamp?(ts)
    rescue TypeError
      Time.now.utc.to_i
    end

    # @param chunks [Array] an input line broken into tokens. The
    #   final token will be a space-separated list of point tags.
    # @return [Hash] of k = v tags.
    #
    def extract_tags(chunks)
      tags_to_hash(chunks.last.split(SPLIT_PATTERN))
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
    # @param line [String] a line of an input file
    # @return [Hash]
    # @raise WavefrontCli::Exception::UnparseableInput if the line
    #   doesn't look right
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def process_line(line)
      return true if line.empty?

      chunks = line.split(SPLIT_PATTERN, fmt.length)
      enough_fields?(line) # can raise exception

      point = { path: extract_path(chunks),
                value: extract_value(chunks) }

      tags = line_tags(chunks)

      point.tap do |p|
        p[:tags]     = tags unless tags.empty?
        p[:ts]       = extract_ts(chunks)        if fmt.include?('t')
        p[:source]   = extract_source(chunks)    if fmt.include?('s')
        p[:interval] = options[:interval] || 'm' if fmt.include?('d')
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # We can get tags from the file, from the -T option, or both.
    # Merge them, making the -T win if there is a collision.
    #
    def line_tags(chunks)
      file_tags = fmt.last == 'T' ? extract_tags(chunks) : {}
      opt_tags = tags_to_hash(options[:tag]) || {}
      file_tags.merge(opt_tags)
    end

    # Takes an array of key=value tags (as produced by docopt) and
    # turns it into a hash of key: value tags.  Anything not of the
    # form key=val is dropped.  If key or value are quoted, we
    # remove the quotes.
    #
    # @param tags [Array[String]]
    # @return [Hash] of k: v tags
    #
    def tags_to_hash(tags)
      return nil unless tags

      [tags].flatten.each_with_object({}) do |t, ret|
        k, v = t.split('=', 2)
        k.gsub!(/^["']|["']$/, '')
        ret[k.to_sym] = v.to_s.gsub(/^["']|["']$/, '') if v
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
    def valid_format?(fmt)
      format_string_has_v_or_d?(fmt)
      format_string_does_not_have_v_and_d?(fmt)
      format_string_is_all_valid_chars?(fmt)
      format_string_has_unique_chars?(fmt)
      format_string_has_big_t_only_at_the_end?(fmt)
    end

    def format_string_has_v_or_d?(fmt)
      return true if fmt.include?('v') || fmt.include?('d')

      raise(WavefrontCli::Exception::UnparseableInput,
            "format string must include 'v' or 'd'")
    end

    def format_string_does_not_have_v_and_d?(fmt)
      return true unless fmt.include?('v') && fmt.include?('d')

      raise(WavefrontCli::Exception::UnparseableInput,
            "'v' and 'd' are mutually exclusive")
    end

    def format_string_is_all_valid_chars?(fmt)
      return true if /^[dmstTv]+$/.match?(fmt)

      raise(WavefrontCli::Exception::UnparseableInput,
            'unsupported field in format string')
    end

    def format_string_has_unique_chars?(fmt)
      return true if fmt.chars.sort == fmt.chars.uniq.sort

      raise(WavefrontCli::Exception::UnparseableInput,
            'repeated field in format string')
    end

    def format_string_has_big_t_only_at_the_end?(fmt)
      return true unless fmt.include?('T')
      return true if fmt.end_with?('T')

      raise(WavefrontCli::Exception::UnparseableInput,
            "if used, 'T' must come at end of format string")
    end

    # Make sure we have the right number of columns, according to
    # the format string. We want to take every precaution we can to
    # stop users accidentally polluting their metric namespace with
    # junk.
    #
    # @param line [String] input line
    # @return [True] if the number of fields is correct
    # @raise WavefrontCli::Exception::UnparseableInput if there
    #   are not the right number of fields.
    #
    def enough_fields?(line)
      ncols = line.split(SPLIT_PATTERN).length
      return true if fmt.include?('T') && ncols >= fmt.length
      return true if ncols == fmt.length

      raise(WavefrontCli::Exception::UnparseableInput,
            format('Expected %<expected>s fields, got %<got>s',
                   expected: fmt.length,
                   got: ncols))
    end

    # Although the SDK does value checking, we'll add another layer
    # of input checking here.  See if the time looks valid. We'll
    # assume anything before 2000/01/01 or after a year from now is
    # wrong.  Arbitrary, but there has to be a cut-off somewhere.
    # @param timestamp [String, Integer] epoch timestamp
    # @return [Bool]
    #
    def valid_timestamp?(timestamp)
      (timestamp.is_a?(Integer) ||
        (timestamp.is_a?(String) && timestamp.match(/^\d+$/))) &&
        timestamp.to_i > 946_684_800 &&
        timestamp.to_i < (Time.now.to_i + 31_557_600)
    end

    def setup_fmt(fmt)
      @fmt = fmt.chars
    end

    def load_data(file)
      File.read(file)
    rescue StandardError
      raise WavefrontCli::Exception::FileNotFound
    end
  end
end
