# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for derived metric definitions.
  #
  class DerivedMetric < Base
    def do_describe
      readable_time(:created, :updated, :createdEpochMillis,
                    :updatedEpochMillis)
      long_output
    end
  end
end
