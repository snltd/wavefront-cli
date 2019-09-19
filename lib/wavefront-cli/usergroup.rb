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
    alias do_permissions do_describe

    def do_create
      wf.create(name: options[:'<name>'],
                permissions: options[:permission])
    end

    def do_add_user
      wf.add_users_to_group(options[:'<id>'], options[:'<user>'])
    end

    def do_remove_user
      wf.remove_users_from_group(options[:'<id>'], options[:'<user>'])
    end

    def do_grant
      wf.grant(options[:'<permission>'], Array(options[:'<id>']))
    end

    def do_revoke
      wf.revoke(options[:'<permission>'], Array(options[:'<id>']))
    end

    def import_to_create(raw)
      raw['emailAddress'] = raw['identifier']
      raw.delete_if { |k, _v| %w[customer identifier].include?(k) }
    end
  end
end
