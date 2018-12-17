require_relative 'base'

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

    def do_enable
      puts "Enabled #{options[:'<id>']}."
    end

    def do_disable
      puts "Disabled #{options[:'<id>']}."
    end
  end
end
