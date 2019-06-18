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

      def do_tag_pathsearch
        require 'wavefront-sdk/search'
        wfs = Wavefront::Search.new(mk_creds, mk_opts)

        query = { key: 'tagpath',
                  value: options[:'<word>'],
                  matchingMethod: 'TAGPATH',
                  negated: false }

        wfs.search(search_key, query, range_hash)
      end
    end
  end
end
