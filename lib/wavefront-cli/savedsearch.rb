require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'savedsearch' API.
  #
  class SavedSearch < WavefrontCli::Base
    def do_list
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def validator_exception
      Wavefront::Exception::InvalidSavedSearchId
    end
  end
end
