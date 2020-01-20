# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output of ingestion policies.
  #
  class IngestionPolicy < Base
  def thing
    'ingestion policy'
  end
=begin
    def do_describe
      readable_time(:startTimeInSeconds, :endTimeInSeconds,
                    :createdEpochMillis, :updatedEpochMillis)
      drop_fields(:hostTagGroupHostNamesGroupAnded, :relevantHostTagsAnded)
      long_output
    end

    def do_list_brief
      multicolumn(:id, :title)
    end

    def do_pending
      do_ongoing
    end

    def do_ongoing
      readable_time_arr(:startTimeInSeconds, :endTimeInSeconds)
      multicolumn(:id, :reason, :startTimeInSeconds, :endTimeInSeconds)
    end
=end
  end
end
