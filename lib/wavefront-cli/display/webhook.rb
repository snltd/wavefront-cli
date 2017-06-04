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

    def do_import
      puts "Imported webhook."
    end

    def do_delete
      puts "Deleted webhook '#{options[:'<id>']}'."
    end
  end
end
