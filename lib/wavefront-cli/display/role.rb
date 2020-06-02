# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for role command
  #
  class Role < Base
    def do_list_brief
      data.map! { |d| d.merge(acct_count: "#{d[:linkedAccountsCount]} accounts",
                              group_count: "#{d[:linkedGroupsCount]} groups") }
      multicolumn(:id, :name, :acct_count, :group_count)
    end

    def do_accounts
      if data.empty?
        puts "No accounts have role '#{options[:'<id>']}'."
      else
        multicolumn(:identifier)
      end
    end

    def do_groups
      if data.empty?
        puts "No groups have role '#{options[:'<id>']}'."
      else
        multicolumn(:id, :name)
      end
    end

    def do_permissions
      if data[:permissions].empty?
        puts "Role '#{options[:'<id>']}' has no permissions."
      else
        puts data[:permissions]
      end
    end

    def do_grant
      puts format("Granted '%<perm>s' permission to '%<id>s'.",
                  perm: options[:'<permission>'],
                  id: options[:'<id>'])
    end

    def do_revoke
      puts format("Revoked '%<perm>s' permission from '%<id>s'.",
                  perm: options[:'<permission>'],
                  id: options[:'<id>'])
    end

    def do_give_to
      puts format("Gave '%<role>s' to %<members>s.",
                  members: quoted(options[:'<member>']),
                  role: options[:'<id>']).fold(TW, 0)
    end

    def do_take_from
      puts format("Took '%<role>s' from %<members>s.",
                  members: quoted(options[:'<member>']),
                  role: options[:'<id>']).fold(TW, 0)
    end
  end
end
