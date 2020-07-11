# frozen_string_literal: true

require_relative 'base'
require_relative 'command_mixins/tag'
require_relative 'command_mixins/acl'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base
    include WavefrontCli::Mixin::Tag
    include WavefrontCli::Mixin::Acl

    def import_fields
      %i[name condition minutes target severity displayExpression tags
         additionalInformation resolveAfterMinutes alertType severityList
         conditions acl]
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

    def do_delete
      smart_delete
    end

    def do_clone
      wf.clone(options[:'<id>'], options[:version]&.to_i)
    end

    def do_summary
      wf.summary
    end

    def do_latest
      wf.versions(options[:'<id>'])
    end

    def do_history
      wf.history(options[:'<id>'], options[:offset], options[:limit])
    end

    def do_affected_hosts
      if options[:'<id>']
        affected_hosts_for_id(options[:'<id>'])
      else
        all_affected_hosts
      end
    end

    def do_currently
      state = options[:'<state>'].to_s

      if wf.respond_to?(state)
        in_state(state)
      else
        abort format("'%<state>s' is not a valid alert state.", state: state)
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

      exit if options[:noop]

      return ret unless ret.is_a?(Wavefront::Response) && ret.empty?

      ok_exit(format('No alerts are currently %<status>s.', status: status))
    end

    # Does the work for #in_state
    # @param status [Symbol,String] the alert status you wish to
    #   find
    # @return Wavefront::Response
    #
    def find_in_state(status)
      search = do_search([format('status=%<status>s', status: status)])

      return if options[:noop]

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
        if raw.key?(:resolveAfterMinutes)
          ret[:resolveMinutes] = raw[:resolveAfterMinutes]
        end

        if raw.key?('customerTagsWithCounts')
          ret[:sharedTags] = raw['customerTagsWithCounts'].keys
        end
      end.compact
    end

    def all_affected_hosts
      cannot_noop!
      in_state(:firing).tap do |r|
        r.response = r.response.items.each_with_object({}) do |alert, aggr|
          aggr[alert[:id]] = affected_hosts_for_id(alert[:id]).response
        end
      end
    end

    def affected_hosts_for_id(id)
      resp = wf.describe(id)

      return if options[:noop]

      return resp unless resp.ok? && resp.response.key?(:failingHostLabelPairs)

      resp.tap do |r|
        r.response = r.response[:failingHostLabelPairs].map { |h| h[:host] }
      end
    end
  end
end
