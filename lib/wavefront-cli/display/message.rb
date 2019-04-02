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
      abort 'Message not found.' if data.empty?
      puts "\n" + data.first.content.fold(TW, 0) + "\n"
    end
  end
end
