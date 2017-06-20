require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'source' API.
  #
  class Source < WavefrontCli::Base
    def do_clear
      wf.delete(options[:'<id>'])
    end

    def do_description_set
      wf.update(options[:'<id>'], description: options[:'<description>'])
    end

    def do_description_clear
      wf.update(options[:'<id>'], { description: ''}, false)
    end
  end
end
