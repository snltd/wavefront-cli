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

    def do_snooze
      puts "Snoozed alert '#{options[:'<id>']}'."
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
