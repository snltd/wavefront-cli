# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for alerts.
  #
  class Alert < Base
    def do_list
      long_output %i[id minutes target status tags hostsUsed
                     condition displayExpression severity
                     additionalInformation]
    end

    def do_list_brief
      multicolumn(:id, :status, :name)
    end

    def do_firing
      readable_time_arr(:time)
      multicolumn(:id, :time, :name)
    end

    def do_snoozed
      readable_time_arr(:time)
      multicolumn(:id, :time, :name)
    end

    def do_describe
      readable_time(:created, :lastProcessedMillis,
                    :lastNotificationMillis, :createdEpochMillis,
                    :updatedEpochMillis, :updated)
      drop_fields(:conditionQBEnabled, :displayExpressionQBEnabled,
                  :displayExpressionQBSerialization)
      long_output
    end

    def do_history
      drop_fields(:inTrash)
      long_output
    end

    def do_snooze
      w = options[:time] ? "for #{options[:time]} seconds" : 'indefinitely'
      puts "Snoozed alert '#{options[:'<id>']}' #{w}."
    end

    def do_unsnooze
      puts "Unsnoozed alert '#{options[:'<id>']}'."
    end

    def do_latest
      puts data.max
    end

    # rubocop:disable Metrics/AbcSize
    def do_summary
      kw = data.keys.map(&:size).max + 2
      data.delete_if { |_k, v| v.zero? } unless options[:all]
      data.sort.each { |k, v| puts format("%-#{kw}s%s", k, v) }
    end
    # rubocop:enable Metrics/AbcSize

    def do_queries
      if options[:brief]
        multicolumn(:condition)
      else
        multicolumn(:id, :condition)
      end
    end

    def do_version
      puts data.max
    end
  end
end
