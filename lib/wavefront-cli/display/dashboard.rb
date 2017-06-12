require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for dashboards.
  #
  class Dashboard < Base
    def do_list
      long_output [:id, :minutes, :target, :status, :tags, :hostsUsed,
                   :condition, :displayExpression, :severity,
                   :additionalInformation]
    end

    def do_describe
      drop_fields(:parameterDetails)
      readable_time(:updatedEpochMillis)
      data[:sections] = data[:sections].map { |s| s[:name] }
      long_output
    end
  end
end
