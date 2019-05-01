module WavefrontCli
  module Mixin
    #
    # Standard tag commands
    #
    module Tag
      def do_tags
        wf.tags(options[:'<id>'])
      end

      def do_tag_add
        wf.tag_add(options[:'<id>'], options[:'<tag>'].first)
      end

      def do_tag_delete
        wf.tag_delete(options[:'<id>'], options[:'<tag>'].first)
      end

      def do_tag_set
        wf.tag_set(options[:'<id>'], options[:'<tag>'])
      end

      def do_tag_clear
        wf.tag_set(options[:'<id>'], [])
      end
    end
  end
end
