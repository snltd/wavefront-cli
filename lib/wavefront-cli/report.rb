require_relative 'base_write'

module WavefrontCli
  class Report < BaseWrite
    def send_point(p)
      wf.write(p)
    rescue Wavefront::Exception::InvalidEndpoint
      abort 'could not speak to API'
    end

    def open_connection; end

    def close_connection; end
  end
end
