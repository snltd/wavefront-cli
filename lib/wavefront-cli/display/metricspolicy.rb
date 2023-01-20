# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output of the metrics policy.
  #
  class MetricsPolicy < Base
    def do_history
      readable_time_arr(:updateTime)
      long_output
    end
  end
end
