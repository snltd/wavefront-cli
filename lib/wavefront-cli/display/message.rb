# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for messages.
  #
  class Message < Base
    def do_list_brief
      multicolumn(:id, :title)
    end

    def do_read
      abort 'Message not found.' unless data && !data.empty?

      puts message_title, data.content.fold(TW, 0), message_sender
    end

    private

    def message_title
      format("\n%<title>s\n%<underline>s\n",
             title: data.title,
             underline: '-' * data.title.length)
    end

    def message_sender
      format("\n%#{TW - 2}<sender>s\n", sender: data.source)
    end
  end
end
