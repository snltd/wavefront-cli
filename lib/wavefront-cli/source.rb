require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'source' API.
  #
  class Source < WavefrontCli::Base

    def do_description_set
      wf.update(options[:'<id>'], description: options[:'<description>'])
    end

    def do_description_clear
      tags = wf.tags(options[:'<id>'])
      #wf.delete(options[:'<id>'])
      #wf.set_tags(options[:'<id>'], tags)
    end
  end
end
