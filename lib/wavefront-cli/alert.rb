require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base
    include WavefrontCli::Constants

    def do_list
      @verbose_response = true
      @flags[:short] = options[:short]
      wf.list(options[:start] || 0, options[:limit] || 100)
    end

    def humanize_list_output(data)
      if flags[:short]
        data.each { |a| puts "#{a['id']}  #{a['name']}" }
      else
        HumanOutput.new(data)
      end
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

    def do_snooze
      wf.snooze(options[:'<id>'], options[:time])
    end

    def do_unsnooze
      wf.snooze(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_summary
      @verbose_response = true
      wf.summary
    end

    # Display the counts of alerts in various states. If a state has no
    # alerts, it is skipped.
    #
    # @param data [Hash] hash of alerts
    #
    def humanize_summary_output(data)
      kw = data.keys.map(&:size).max + 2
      data.sort.reject { |_k, v| v.zero? }.each do |k, v|
        puts format("%-#{kw}s%s", k, v)
      end
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
