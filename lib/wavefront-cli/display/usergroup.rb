# frozen_string_literal: true

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
      puts format("Added %<quoted_user>s to '%<group_id>s'.",
                  quoted_user: quoted(options[:'<user>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_remove_user
      puts format("Removed %<quoted_user>s from '%<group_id>s'.",
                  quoted_user: quoted(options[:'<user>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_add_role
      puts format("Added %<quoted_role>s to '%<group_id>s'.",
                  quoted_role: quoted(options[:'<role>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_remove_role
      puts format("Removed %<quoted_role>s from '%<group_id>s'.",
                  quoted_role: quoted(options[:'<role>']),
                  group_id: options[:'<id>']).fold(TW, 0)
    end

    def do_users
      puts(if !data.include?(:users) || data[:users].empty?
             "No users in group '#{options[:'<id>']}'."
           else
             data[:users]
           end)
    end

    def do_permissions
      puts(if !data.include?(:permissions) || data[:permissions].empty?
             "Group '#{options[:'<id>']}' has no permissions."
           else
             data[:permissions]
           end)
    end
  end
end
