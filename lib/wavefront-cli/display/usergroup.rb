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
      puts "Deleted user group '#{options[:'<id>']}'."
    end

    def do_add_user
      puts format("Added %s to '%s'.", quoted_users,
                  options[:'<id>']).fold(TW, 0)
    end

    def do_remove_user
      puts format("Removed %s from '%s'.", quoted_users,
                  options[:'<id>']).fold(TW, 0)
    end

    def do_grant
      puts format("Granted '%s' permission to '%s'.",
                  options[:'<permission>'], options[:'<id>'])
    end

    def do_revoke
      puts format("Revoked '%s' permission from '%s'.",
                  options[:'<permission>'], options[:'<id>'])
    end

    def do_users
      puts(if ! data.include?(:users) || data[:users].empty?
             "No users in group '#{options[:'<id>']}'."
           else
             data[:users]
           end)
    end

    def do_permissions
      puts(if ! data.include?(:permissions) || data[:permissions].empty?
            "Group '#{options[:'<id>']}' has no permissions."
           else
            data[:permissions]
           end)
    end

    private

    def quoted_users
      options[:'<user>'].map{ |u| "'#{u}'" }.join(', ')
    end
  end
end
