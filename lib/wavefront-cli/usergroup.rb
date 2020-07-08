# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'usergroup' API.
  #
  class UserGroup < WavefrontCli::Base
    def validator_exception
      Wavefront::Exception::InvalidUserGroupId
    end

    alias do_users do_describe
    alias do_roles do_describe
    alias do_permissions do_describe

    def do_create
      wf.create(name: options[:'<name>'], roleIDs: options[:roleid])
    end

    def do_add_to
      wf.add_users_to_group(options[:'<id>'], options[:'<user>'])
    end

    def do_remove_from
      wf.remove_users_from_group(options[:'<id>'], options[:'<user>'])
    end

    def do_add_role
      wf.add_roles_to_group(options[:'<id>'], options[:'<role>'])
    end

    def do_remove_role
      wf.remove_roles_from_group(options[:'<id>'], options[:'<role>'])
    end

    def import_to_create(raw)
      raw['emailAddress'] = raw['identifier']
      raw.delete_if { |k, _v| %w[customer identifier].include?(k) }
    end
  end
end
