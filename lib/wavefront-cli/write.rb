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
      unless options[:metric] || options[:format].include?('m')
        raise WavefrontCli::Exception::InsufficientData.new(
          "Supply a metric path in the file or with '-m'.")
      end

      unless options[:proxy]
        raise WavefrontCli::Exception::CredentialError.new(
          'Missing proxy address.')
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
