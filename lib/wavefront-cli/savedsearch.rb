require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'savedsearch' API.
  #
  class SavedSearch < WavefrontCli::Base
    def do_list
      @response = :verbose
      @col2 = 'entityType'
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end
  end
end
