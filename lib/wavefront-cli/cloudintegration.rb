require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'cloudintegration' API.
  #
  class CloudIntegration < WavefrontCli::Base
    def do_list
      @verbose_response = true
      @col2 = 'service'
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end
  end
end
