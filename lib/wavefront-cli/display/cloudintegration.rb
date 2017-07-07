require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for cloud integrations.
  #
  class CloudIntegration < Base
    def do_list_brief
      multicolumn(:id, :service)
    end

    def do_describe
      readable_time(:lastReceivedDataPointMs, :lastProcessingTimestamp)
      drop_fields(:forceSave, :inTrash, :deleted)
      long_output
    end
  end
end
