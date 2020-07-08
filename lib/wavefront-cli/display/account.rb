# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for account management.
  #
  class Account < Base
    def do_list_brief
      filter_user_list
      puts(data.map { |account| account[:identifier] })
    end

    def do_list
      filter_user_list
      super
    end

    def do_role_add_to
      puts format("Gave %<quoted_roles>s to '%<id>s'.",
                  id: options[:'<id>'],
                  quoted_roles: quoted(options[:'<role>']))
    end

    def do_role_remove_from
      puts format("Removed %<quoted_roles>s from '%<id>s'.",
                  id: options[:'<id>'],
                  quoted_roles: quoted(options[:'<role>']))
    end

    def do_roles
      roles = data.fetch(:roles, [])
      puts roles.empty? ? "'#{options[:'<id>']}' has no roles." : roles
    end

    def do_group_add_to
      puts format("Added '%<id>s' to %<quoted_group>s.",
                  id: options[:'<id>'],
                  quoted_group: quoted(options[:'<group>']))
    end

    def do_group_remove_from
      puts format("Removed '%<id>s' from %<quoted_group>s.",
                  id: options[:'<id>'],
                  quoted_group: quoted(options[:'<group>']))
    end

    def do_groups
      groups = data.fetch(:userGroups, [])

      if groups.empty?
        puts "'#{options[:'<id>']}' does not belong to any groups."
      else
        puts groups.sort
      end
    end

    def do_business_functions
      puts data.sort
    end

    def do_grant_to
      puts format("Granted '%<permission>s' to %<quoted_accounts>s.",
                  permission: options[:'<permission>'],
                  quoted_accounts: quoted(options[:'<account>']))
    end

    def do_revoke_from
      puts format("Revoked '%<permission>s' from %<quoted_accounts>s.",
                  permission: options[:'<permission>'],
                  quoted_accounts: quoted(options[:'<account>']))
    end

    def do_permissions
      perms = data.fetch(:groups, [])

      if perms.empty?
        puts "'#{options[:'<id>']}' does not have any permissions directly " \
             'attached.'
      else
        puts perms.sort
      end
    end

    def do_ingestionpolicy_add_to
      puts format("Added '%<policy>s' to '%<id>s'.",
                  id: options[:'<id>'],
                  policy: options[:'<policy>'])
    end

    def do_ingestionpolicy_remove_from
      puts format("Removed '%<policy>s' from '%<id>s'.",
                  id: options[:'<id>'],
                  policy: options[:'<policy>'])
    end

    def do_ingestionpolicy
      policy = data.fetch(:ingestionPolicyId, [])

      if policy.empty?
        puts "'#{options[:'<id>']}' has no ingestion policy."
      else
        puts policy
      end
    end

    def do_invite_user
      puts format("Sent invitation to '%<id>s'.", id: options[:'<id>'])
    end

    private

    def filter_user_list
      if options[:user]
        data.delete_if { |a| a[:identifier].start_with?('sa::') }
      elsif options[:service]
        data.delete_if { |a| !a[:identifier].start_with?('sa::') }
      end
    end
  end
end
