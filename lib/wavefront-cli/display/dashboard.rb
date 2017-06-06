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
  end
end
