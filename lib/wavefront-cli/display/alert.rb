require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for alerts.
  #
  class Alert < Base
    def do_list
      long_output [:id, :minutes, :target, :status, :tags, :hostsUsed,
                   :condition, :displayExpression, :severity,
                   :additionalInformation]
    end

    def do_list_brief
      multicolumn(:id, :status, :name)
    end

    def do_describe
      readable_time(:created, :lastProcessedMillis,
                    :lastNotificationMillis, :createdEpochMillis,
                    :updatedEpochMillis, :updated)
      drop_fields(:conditionQBEnabled, :displayExpressionQBEnabled,
                  :displayExpressionQBSerialization)
      long_output
    end

    def do_snooze
      print "Snoozed alert '#{options[:'<id>']}' "

      puts options[:time] ? "for #{options[:time]} seconds." :
                            'indefinitely.'
    end

    def do_unsnooze
      puts "Unsnoozed alert '#{options[:'<id>']}'."
    end

    def do_summary
      kw = data.keys.map(&:size).max + 2
      data.delete_if { |_k, v| v.zero? } unless options[:all]
      data.sort.each { |k, v| puts format("%-#{kw}s%s", k, v) }
    end
  end
end
