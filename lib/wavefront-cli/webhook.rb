require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'webhook' API.
  #
  class Webhook < WavefrontCli::Base
    def do_list
      @response = :verbose
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
      wf.describe(options[:'<user>'])
    end

    def do_delete
      wf.delete(options[:'<user>'])
    end
  end
end
