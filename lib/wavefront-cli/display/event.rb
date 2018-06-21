require 'date'
require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for events.
  #
  class Event < Base
    def do_describe
      readable_time(:startTime, :endTime, :updatedAt, :createdAt,
                    :createdEpochMillis, :updatedEpochMillis)
      long_output
    end

    def do_list_brief
      multicolumn(:id, :runningState)
    end
  end
end
