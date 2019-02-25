require_relative 'base_write'

module WavefrontCli
  #
  # Write metrics direct to Wavefront. Sister of WavefrontCli::Write
  #
  class Report < BaseWrite
    def send_point(point)
      call_write(point)
    rescue Wavefront::Exception::InvalidEndpoint
      abort 'could not speak to API'
    end

    def open_connection; end

    def close_connection; end
  end
end
