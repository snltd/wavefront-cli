# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for saved searches.
  #
  class SavedSearch < Base
    def do_describe
      readable_time(:createdEpochMillis, :updatedEpochMillis)
      long_output
    end

    def do_list_brief
      multicolumn(:id, :entityType)
    end
  end
end
