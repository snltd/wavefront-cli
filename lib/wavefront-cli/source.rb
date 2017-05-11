require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'source' API.
  #
  class Source < WavefrontCli::Base
    def do_list
      @response = :verbose
      @col2 = 'description'
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_tags
      @response = :verbose
      wf.tags(options[:'<id>'])
    end

    def do_tag_add
      wf.tag_add(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_delete
      wf.tag_delete(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_set
      wf.tag_set(options[:'<id>'], Array(options[:'<tag>']))
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end
  end
end
