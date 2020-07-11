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
      wf.add_roles(options[:'<id>'], options[:'<role>'])
    end

    def do_role_remove_from
      wf_account_id?(options[:'<id>'])
      wf.remove_roles(options[:'<id>'], options[:'<role>'])
    end

    def do_group_add_to
      wf_account_id?(options[:'<id>'])
      wf.add_user_groups(options[:'<id>'], options[:'<group>'])
    end

    def do_group_remove_from
      wf_account_id?(options[:'<id>'])
      wf.remove_user_groups(options[:'<id>'], options[:'<group>'])
    end

    def do_business_functions
      wf_user_id?(options[:'<id>'])
      wf.business_functions(options[:'<id>'])
    end

    def do_grant_to
      wf.grant(options[:'<account>'], options[:'<permission>'])
    end

    def do_revoke_from
      wf.revoke(options[:'<account>'], options[:'<permission>'])
    end

    def do_ingestionpolicy_add_to
      wf_account_id?(options[:'<id>'])
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

    def extra_validation
      validate_policy
      validate_permission
      validate_roles
      validate_groups
      validate_accounts
    end

    private

    def validate_policy
      wf_ingestionpolicy_id?(options[:'<policy>']) if options[:'<policy>']
    end

    def validate_permission
      wf_permission?(options[:'<permission>']) if options[:'<permission>']
    end

    def validate_roles
      options[:'<role>'].each { |r| wf_role_id?(r) }
    end

    def validate_groups
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }
    end

    def validate_accounts
      options[:'<account>'].each { |a| wf_account_id?(a) }
    end

    # Object used to create and invite users. We deal with the permissions
    # seperately because if we don't supply any and they get compacted out,
    # the user is created with a default set of perms, and we don't want that.
    #
    def user_body
      raw = {
        emailAddress: options[:'<id>'],
        roles: options[:roleid],
        ingestionPolicyId: options[:policyid],
        userGroups: options[:groupid]
      }.reject { |_k, v| v&.empty? }.compact

      raw[:groups] = options[:permission]
      raw
    end
  end
end
