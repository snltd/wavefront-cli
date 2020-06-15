# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'account' API.
  #
  class Account < WavefrontCli::Base
    alias do_roles do_describe
    alias do_groups do_describe
    alias do_ingestionpolicy do_describe
    alias do_permissions do_describe

    def do_role_add_to
      wf_account_id?(options[:'<id>'])
      options[:'<role>'].each { |g| wf_role_id?(g) }
      wf.add_roles(options[:'<id>'], options[:'<role>'])
    end

    def do_role_remove_from
      wf_account_id?(options[:'<id>'])
      options[:'<role>'].each { |g| wf_role_id?(g) }
      wf.remove_roles(options[:'<id>'], options[:'<role>'])
    end

    def do_group_add_to
      wf_account_id?(options[:'<id>'])
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }
      wf.add_user_groups(options[:'<id>'], options[:'<group>'])
    end

    def do_group_remove_from
      wf_account_id?(options[:'<id>'])
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }
      wf.remove_user_groups(options[:'<id>'], options[:'<group>'])
    end

    def do_business_functions
      wf_user_id?(options[:'<id>'])
      wf.business_functions(options[:'<id>'])
    end

    def do_grant_to
      wf_permission?(options[:'<permission>'])
      options[:'<account>'].each { |a| wf_account_id?(a) }
      wf.grant(options[:'<account>'], options[:'<permission>'])
    end

    def do_revoke_from
      wf_permission?(options[:'<permission>'])
      options[:'<account>'].each { |a| wf_account_id?(a) }
      wf.revoke(options[:'<account>'], options[:'<permission>'])
    end

    def do_ingestionpolicy_add_to
      wf_account_id?(options[:'<id>'])
      wf_ingestionpolicy_id?(options[:'<policy>'])
      wf.add_ingestion_policy(options[:'<policy>'], [options[:'<id>']])
    end

    def do_ingestionpolicy_remove_from
      wf_account_id?(options[:'<id>'])
      wf_ingestionpolicy_id?(options[:'<policy>'])
      wf.remove_ingestion_policy(options[:'<policy>'], [options[:'<id>']])
    end

    def do_create_user
      wf_user_id?(options[:'<id>'])
      wf.user_create(user_body)
    end

    def do_invite_user
      wf_user_id?(options[:'<id>'])
      wf.user_invite([user_body])
    end

    def do_validate
      wf.validate_accounts(options[:'<account>'])
    end

    private

    # Object used to create and invite users.
    #
    def user_body
      { emailAddress: options[:'<id>'],
        groups: options[:permission],
        roles: options[:roleid],
        ingestionPolicyId: options[:policyid],
        userGroups: options[:groupid] }.reject { |_k, v| v&.empty? }.compact
    end

    #     def do_leave
    #       wf.remove_groups_from_user(options[:'<id>'], options[:'<group>'])
    #     end
    #
    #     def do_grant
    #       wf.grant(options[:'<id>'], options[:'<privilege>'])
    #     end
    #
    #     def do_revoke
    #       wf.revoke(options[:'<id>'], options[:'<privilege>'])
    #     end
    #
    #
    #     def import_to_create(raw)
    #       { emailAddress: raw['items']['identifier'],
    #         groups: raw['items']['groups'] }.tap do |r|
    #         if raw['items'].key?('userGroups')
    #           r['userGroups'] = raw['items']['userGroups'].map { |g| g['id'] }
    #         end
    #       end
    #     end
    #
    #     # Because of the way docopt works, we have to call the user ID
    #     # parameter something else on the delete command. This means the
    #     # automatic validtion doesn't work, and we have to do it
    #     # ourselves.
    #     #
    #     def extra_validation
    #       options[:'<user>']&.each { |u| validate_user(u) }
    #     end
    #
    #     def validate_user(user)
    #       wf_user_id?(user)
    #     rescue Wavefront::Exception::InvalidUserId
    #       abort failed_validation_message(user)
    #     end
    #
    #     def item_dump_call
    #       wf.list.response.items
    #     end
  end
end
