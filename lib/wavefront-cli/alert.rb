require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base
    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_snooze
      wf.snooze(options[:'<id>'], options[:time])
    end

    def do_unsnooze
      wf.unsnooze(options[:'<id>'])
    end

    def do_delete
      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts "#{word} deleting alert '#{options[:'<id>']}'."
      wf.delete(options[:'<id>'])
    end

    def do_summary
      wf.summary
    end

    def do_history
      wf.history(options[:'<id>'], options[:offset], options[:limit])
    end

    def do_firing
      find_in_state(:firing)
    end

    def do_snoozed
      find_in_state(:snoozed)
    end

    # Does the work for #do_firing() and #do_snoozed()
    # @param status [Symbol,String] the alert status you wish to
    #   find
    # @return Wavefront::Response
    #
    def find_in_state(status)
      search = do_search([format('status=%s', status)])

      items = search.response.items.map do |i|
        { name: i.name, id: i.id, startTime: i.event.startTime }
      end

      search.tap { |s| s.response[:items] = items }
    end

    # Take a previously exported alert, and construct a hash which
    # create() can use to re-create it.
    #
    # @param raw [Hash] Ruby hash of imported data
    #
    def import_to_create(raw)
      ret = %w[name condition minutes target severity displayExpression
               additionalInformation].each_with_object({}) do |k, aggr|
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
