require_relative './base'

module WavefrontDisplay

  # Format human-readable output for webhooks.
  #
  class Webhook < Base
    def do_list
      long_output([:id, :description, :createdEpochMillis,
                   :updatedEpochMillis, :updaterId, :creatorId,
                   :title])
    end

    def do_list_brief
      terse_output(:id, :title)
    end
  end
end
