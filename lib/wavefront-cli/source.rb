require_relative 'base'
require_relative 'command_mixins/tag'

module WavefrontCli
  #
  # CLI coverage for the v2 'source' API.
  #
  class Source < WavefrontCli::Base
    include WavefrontCli::Mixin::Tag

    def do_list
      wf.list(options[:limit], options[:cursor])
    end

    def do_clear
      wf.delete(options[:'<id>'])
    end

    def do_description_set
      wf.description_set(options[:'<id>'], options[:'<description>'])
    end

    def do_description_clear
      wf.description_delete(options[:'<id>'])
    end
  end
end
