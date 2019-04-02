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

      puts "\n" + data.title + "\n" + '-' * data.title.size,
           "\n" + data.content.fold(TW, 0) + "\n",
           format("%#{TW - 2}s\n", data.source)
    end
  end
end
