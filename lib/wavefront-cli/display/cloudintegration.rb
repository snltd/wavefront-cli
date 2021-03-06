# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for cloud integrations.
  #
  class CloudIntegration < Base
    def do_list_brief
      multicolumn(:id, :service, :name)
    end

    def do_describe
      readable_time(:lastReceivedDataPointMs, :lastProcessingTimestamp,
                    :createdEpochMillis, :updatedEpochMillis)
      drop_fields(:forceSave, :inTrash, :deleted)
      long_output
    end

    def do_enable
      puts "Enabled '#{options[:'<id>']}'."
    end

    def do_disable
      puts "Disabled '#{options[:'<id>']}'."
    end

    def do_awsid_generate
      puts data
    end

    def do_awsid_delete
      puts "Deleted external ID '#{options[:'<external_id>']}'."
    end

    def do_awsid_confirm
      puts "'#{data}' is a registered external ID."
    end
  end
end
