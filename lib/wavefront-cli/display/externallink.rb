require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for external links.
  #
  class ExternalLink < Base
    def do_describe
      readable_time(:createdEpochMillis, :updatedEpochMillis)
      long_output
    end
  end
end
