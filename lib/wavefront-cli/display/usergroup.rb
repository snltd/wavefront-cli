require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for user management.
  #
  class UserGroup < Base
    def do_list_brief
      multicolumn(:id, :name, :userCount)
    end

    def do_delete
      puts "Deleted user group '#{options[:'<id>']}."
    end

    def do_add_user
      puts format('Added %s to %s.', options[:'<user>'].join(', '),
                  options[:'<id>']).fold(TW, 0)
    end

    def do_remove_user
      puts format("Removed '%s' from %s.", options[:'<user>'].join(', '),
                  options[:'<id>']).fold(TW, 0)
    end

    def do_grant
      puts format("Granted '%s' permission to %s.",
                  options[:'<permission>'], options[:'<id>'])
    end

    def do_revoke
      puts format("Revoked '%s' permission from %s.",
                  options[:'<permission>'], options[:'<id>'])
    end

    def do_users
      if data.users.empty?
        puts 'No users in group.'
      else
        data.users.each { |u| puts u }
      end
    end

    def do_permissions
      if data.permissions.empty?
        puts 'Group has no permissions.'
      else
        data.permissions.each { |u| puts u }
      end
    end
  end
end
