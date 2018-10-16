require_relative 'base_write'

module WavefrontCli
  #
  # Send points via a proxy. This inherits from the same base class
  # as Report, but has to do a couple of things differently, as it
  # speaks to a proxy rather than to the API.
  #
  class Write < BaseWrite
    def do_distribution
      p = { path:     options[:'<metric>'],
            interval: options[:interval] || 'M',
            value:    mk_dist,
            tags:     tags_to_hash(options[:tag]) }

      p[:source] = options[:host] if options[:host]
      p[:ts] = parse_time(options[:time]) if options[:time]
      send_point(p)
    end

    def mk_dist
      wf.mk_distribution(options[:'<val>'].map(&:to_f))
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
      options[:infileformat] && options[:infileformat].include?('d')
    end

    def mk_creds
      { proxy: options[:proxy], port: options[:port] || default_port }
    end

    def default_port
      distribution? ? 40000 : 2878
    end

    def validate_opts
      validate_opts_file if options[:file]

      return true if options[:proxy]
      raise(WavefrontCli::Exception::CredentialError, 'No proxy address.')
    end

    def validate_opts_file
      unless options[:metric] || (options.key?(:infileformat) &&
                                  options[:infileformat].include?('m'))
        raise(WavefrontCli::Exception::InsufficientData,
              "Supply a metric path in the file or with '-m'.")
      end
    end

    def open_connection
      wf.open
    end

    def close_connection
      wf.close
    end
  end
end
