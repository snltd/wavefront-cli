# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for the access policy.
  #
  class AccessPolicy < Base
    def do_describe
      p data
      # readable_time(:lastReceivedDataPointMs, :lastProcessingTimestamp,
      #               :createdEpochMillis, :updatedEpochMillis)
      # drop_fields(:forceSave, :inTrash, :deleted)
      # long_output
    end
  end
end
