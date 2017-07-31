require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for messages.
  #
  class Message < Base
    def do_list_brief
      multicolumn(:id, :title)
    end
  end
end
