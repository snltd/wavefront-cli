# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'role' API.
  #
  class Role < WavefrontCli::Base
    alias do_permissions do_describe

    def do_create
      wf.create({ name: options[:'<name>'],
                  description: options[:description],
                  permissions: options[:permission] }.compact)
    end

    def do_accounts
      things_with_role(:account, options[:'<id>'])
    end

    def do_groups
      things_with_role(:usergroup, options[:'<id>'])
    end

    def do_give_to
      wf.add_assignees(options[:'<id>'], options[:'<member>'])
    end

    def do_take_from
      wf.remove_assignees(options[:'<id>'], options[:'<member>'])
    end

    def do_grant
      wf.grant(options[:'<permission>'], Array(options[:'<id>']))
    end

    def do_revoke
      wf.revoke(options[:'<permission>'], Array(options[:'<id>']))
    end

    private

    # Search for objects of the given type with the given role
    #
    def things_with_role(thing, role)
      require 'wavefront-sdk/search'
      wfs = Wavefront::Search.new(mk_creds, mk_opts)
      wfs.search(thing,
                 conds_to_query(["roles~#{role}"]),
                 limit: :all, sort_field: :id)
    end
  end
end
