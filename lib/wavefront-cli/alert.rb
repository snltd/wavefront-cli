require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base
    def import_fields
      %w[name condition minutes target severity displayExpression
         tags additionalInformation]
    end

    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_snooze
      wf.snooze(options[:'<id>'], options[:time])
    end

    def do_unsnooze
      wf.unsnooze(options[:'<id>'])
    end

    # rubocop:disable Metrics/AbcSize
    def do_delete
      cannot_noop!

      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts "#{word} deleting alert '#{options[:'<id>']}'."
      wf.delete(options[:'<id>'])
    end
    # rubocop:enable Metrics/AbcSize

    def do_summary
      wf.summary
    end

    def do_history
      wf.history(options[:'<id>'], options[:offset], options[:limit])
    end

    def do_currently
      state = options[:'<state>'].to_s

      if wf.respond_to?(state)
        in_state(state)
      else
        abort format("'%s' is not a valid alert state.", state)
      end
    end

    def do_firing
      in_state(:firing)
    end

    def do_snoozed
      in_state(:snoozed)
    end

    def do_queries
      resp, data = one_or_all

      resp.tap do |r|
        r.response.items = data.map do |a|
          { id: a.id, condition: a.condition }
        end
      end
    end

    def do_install
      wf.install(options[:'<id>'])
    end

    def do_uninstall
      wf.uninstall(options[:'<id>'])
    end

    # How many alerts are in the given state? If none, say so,
    # rather than just printing nothing.
    #
    def in_state(status)
      options[:all] = true
      ret = find_in_state(status)
      ok_exit(format('No alerts are currently %s.', status)) if ret.empty?
      ret
    end

    # Does the work for #in_state
    # @param status [Symbol,String] the alert status you wish to
    #   find
    # @return Wavefront::Response
    #
    def find_in_state(status)
      search = do_search([format('status=%s', status)])

      items = search.response.items.map do |i|
        { name: i.name, id: i.id, time: state_time(i) }
      end

      search.tap { |s| s.response[:items] = items }
    end

    # Snoozed alerts don't have a start time, they have a "snoozed"
    # time. This is -1 if they are snoozed forever: the formatting
    # methods know what to do with that.
    # @return [Integer]
    #
    def state_time(item)
      return item[:event][:startTime] if item.key?(:event)
      return item[:snoozed] if item.key?(:snoozed)
      nil
    end

    # Take a previously exported alert, and construct a hash which
    # create() can use to re-create it.
    #
    # @param raw [Hash] Ruby hash of imported data
    #
    def import_to_create(raw)
      import_fields.each_with_object({}) { |k, a| a[k.to_sym] = raw[k] }
                   .tap do |ret|

        if raw.key?('resolveAfterMinutes')
          ret[:resolveMinutes] = raw['resolveAfterMinutes']
        end

        if raw.key?('customerTagsWithCounts')
          ret[:sharedTags] = raw['customerTagsWithCounts'].keys
        end
      end
    end
  end
end
