require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'message' API.
  #
  class Message < WavefrontCli::Base
    def do_list
      @verbose_response = true
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_mark
      wf.read(options[:'<id>'])
    end
  end
end
