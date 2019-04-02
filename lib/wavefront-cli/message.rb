require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'message' API.
  #
  class Message < WavefrontCli::Base
    def no_api_response
      %w[do_read]
    end

    # There's an extra flag to "list" that no other commands have.
    #
    def do_list
      wf.list(options[:offset] || 0, options[:limit] || 100, !options[:all])
    end

    def do_read
      resp = wf.list(0, :all, false).response.items.select do |msg|
        msg[:id] == options[:'<id>']
      end

      do_mark
      resp
    end

    def do_mark
      wf.read(options[:'<id>'])
    end
  end
end
