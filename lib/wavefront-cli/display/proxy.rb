require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for proxies.
  #
  class Proxy < Base
    def do_describe
      readable_time(:lastCheckInTime)
      long_output
    end
  end
end
