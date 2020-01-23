# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output of ingestion policies.
  #
  class IngestionPolicy < Base
    def do_add_user
      puts format("Added %<quoted_user>s to '%<group_id>s'.",
                  quoted_user: quoted(options[:'<user>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_remove_user
      puts format("Removed %<quoted_user>s from '%<group_id>s'.",
                  quoted_user: quoted(options[:'<user>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_for
      puts data
    end

    alias do_members do_for
  end
end
