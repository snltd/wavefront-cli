# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for webhooks.
  #
  class Webhook < Base
    def do_list
      long_output(%i[id title description createdEpochMillis
                     updatedEpochMillis updaterId creatorId])
    end

    def do_list_brief
      multicolumn(:id, :title)
    end

    def do_describe
      readable_time(:createdEpochMillis, :updatedEpochMillis)
      drop_fields(:template)
      long_output
    end
  end
end
