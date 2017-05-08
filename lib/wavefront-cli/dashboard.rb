require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
    include WavefrontCli::Constants

    def format_var
      :dashformat
    end

    def do_list
      @verbose_response = true
      @flags[:short] = options[:short]
      wf.list(options[:start] || 0, options[:limit] || 100)
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_import
      wf.create(load_file(options[:'<file>']))
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_history
      @verbose_response = true
      wf.history(options[:'<id>'])
    end

    def do_tags
      @verbose_response = true
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
