# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for user management.
  #
  class User < Base
    def do_list_brief
      data.each { |user| puts user[:identifier] }
    end

    def do_groups
      groups = data.first.userGroups

      if groups.empty?
        puts 'User does not belong to any groups.'
      else
        groups.each { |u| puts format('%<id>s (%<name>s)', u) }
      end
    end

    def do_privileges
      puts(if data.first[:groups].empty?
             'User does not have any Wavefront privileges.'
           else
             data.first[:groups]
           end)
    end

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

    def do_invite
      puts format("Sent invitation to '%<id>s'.", id: options[:'<id>'])
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
      puts format("Added '%<id>s' to %<quoted_group>s.",
                  id: options[:'<id>'],
                  quoted_group: quoted(options[:'<group>']))
    end

    def do_leave
      puts format("Removed '%<id>s' from %<quoted_group>s.",
                  id: options[:'<id>'],
                  quoted_group: quoted(options[:'<group>']))
    end

    def do_business_functions
      puts data.sort
    end
  end
end
