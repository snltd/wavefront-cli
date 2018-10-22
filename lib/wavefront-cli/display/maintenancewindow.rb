require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for maintenance windows.
  #
  class MaintenanceWindow < Base
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
  end
end
