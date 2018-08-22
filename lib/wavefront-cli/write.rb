require_relative 'base_write'

module WavefrontCli
  #
  # Send points via a proxy. This inherits from the same base class
  # as Report, but has to do a couple of things differently, as it
  # speaks to a proxy rather than to the API.
  #
  class Write < BaseWrite
    def mk_creds
      { proxy: options[:proxy], port: options[:port] || 2878 }
    end

    def validate_opts
      validate_opts_file if options[:file]

      return true if options[:proxy]
      raise(WavefrontCli::Exception::CredentialError,
            'Missing proxy address.')
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
