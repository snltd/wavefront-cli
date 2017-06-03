require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base

    def do_list
      @response = :verbose
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
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

    def do_snooze
      wf.snooze(options[:'<id>'], options[:time])
    end

    def do_unsnooze
      wf.unsnooze(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_summary
      @response = :verbose
      wf.summary
    end

    def do_history
      @response = :verbose
      wf.history(options[:'<id>'])
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
      wf.tag_set(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end

    # Take a previously exported alert, and construct a hash which
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
