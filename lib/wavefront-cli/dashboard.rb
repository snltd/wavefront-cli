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

    def humanize_list_output(data)
      ho = HumanOutput.new(data)
      flags[:short] ?  ho.terse : ho.two_columns
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_import
      raw = load_file(options[:'<file>'])

      begin
        prepped = import_to_create(raw)
      rescue => e
        puts e if options[:debug]
        raise 'could not parse input.'
      end

      wf.create(prepped)
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
      wf.tag_add(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_delete
      wf.tag_delete(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_set
      wf.tag_set(options[:'<id>'], Array(options[:'<tag>']))
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end

    def humanize_tags_output(data)
      data.sort.each { |t| puts t }
    end

    # Take a previously exported dashboard, and construct a hash which
    # create() can use to re-create it.
    #
    # @param raw [Hash] Ruby hash of imported data
    #
    def import_to_create(raw)
      ret = %w(name condition minutes target severity displayExpression
               additionalInformation).each_with_object({}) do |k, aggr|
        aggr[k.to_sym] = raw[k]
      end

      if raw.key?('resolveAfterMinutes')
        ret[:resolveMinutes] = raw['resolveAfterMinutes']
      end

      if raw.key?('customerTagsWithCounts')
        ret[:sharedTags] = raw['customerTagsWithCounts'].keys
      end
      ret
    end
  end
end
