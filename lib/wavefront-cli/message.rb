require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'message' API.
  #
  class Message < WavefrontCli::Base
    #
    # There's an extra flag to "list" that no other commands have.
    #
    def do_list
      wf.list(options[:offset] || 0, options[:limit] || 100, !options[:all])
    end

    def do_mark
      wf.read(options[:'<id>'])
    end
  end
end
