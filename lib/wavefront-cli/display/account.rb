# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for account management.
  #
  class Account < Base
    def do_list_brief
      filter_user_list
      puts data.map { |account| account[:identifier] }
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

    def do_invite
      puts format("Sent invitation to '%<id>s'.", id: options[:'<id>'])
    end

    private

    def filter_user_list
      if options[:user]
        data.delete_if { |a| a[:identifier].start_with?('sa::') }
      elsif options[:service]
        data.delete_if { |a| ! a[:identifier].start_with?('sa::') }
      end
    end

=begin
    def do_create
      info = data[0]
      puts format("Created user '%<user>s'.\nPermission groups\n" \
                  "%<perm_groups>s\nUser groups\n%<user_groups>s",
                  user: info[:identifier],
                  perm_groups: groups_as_string(info[:groups]),
                  user_groups: user_groups_as_string(info[:userGroups]))
    end

    def groups_as_string(groups)
      return '  <none>' if groups.empty?

      data.response.groups.map do |g|
        format('  %<group>s', group: g)
      end.join("\n  ")
    end

    def user_groups_as_string(groups)
      return '  <none>' if groups.empty?

      groups.map { |g| format('  %<name>s (%<id>s)', g) }.join("\n")
    end

    def do_delete
      puts format('Deleted %<quoted_user>s.',
                  quoted_user: quoted(options[:'<user>']))
    end

    def do_grant
      puts format("Granted '%<priv>s' to '%<id>s'.",
                  priv: options[:'<privilege>'],
                  id: options[:'<id>'])
    end

    def do_revoke
      puts format("Revoked '%<priv>s' from '%<id>s'.",
                  priv: options[:'<privilege>'],
                  id: options[:'<id>'])
    end

    def do_join
    end

    def do_leave
      puts format("Removed '%<id>s' from %<quoted_group>s.",
                  id: options[:'<id>'],
                  quoted_group: quoted(options[:'<group>']))
    end

    def do_validate_brief
      valid = data[0][:validUsers]
      invalid = data[0][:invalidIdentifiers]

      puts 'valid ',
           valid.empty? ? '  <none>' : valid.map { |u| "  #{u[:identifier]}" }

      puts 'invalid',
           invalid.empty? ? '  <none>' : invalid.map { |u| "  #{u}" }
    end
=end
  end
end
