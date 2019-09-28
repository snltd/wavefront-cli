# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'serviceaccount' API.
  #
  class ServiceAccount < WavefrontCli::Base
    def do_list
      wf.list
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    alias do_groups do_describe
    alias do_privileges do_describe

    def do_create
      wf_user_id?(options[:'<id>'])
      wf.create(user_body)
    end

    def do_activate
      wf.activate(options[:'<id>'])
    end

    def do_deactivate
      wf.deactivate(options[:'<id>'])
    end

    def do_join
      cannot_noop!
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }

      body = add_groups_to_list(current_state, options[:'<group>'])
      wf.update(options[:'<id>'], body)
    end

    def do_leave
      cannot_noop!
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }

      body = remove_groups_from_list(current_state, options[:'<group>'])
      wf.update(options[:'<id>'], body)
    end

    def do_grant
      cannot_noop!
      wf_permission?(options[:'<privilege>'])

      body = add_priv_to_list(current_state, options[:'<privilege>'])
      wf.update(options[:'<id>'], body)
    end

    def do_revoke
      cannot_noop!
      wf_permission?(options[:'<privilege>'])

      body = remove_priv_from_list(current_state, options[:'<privilege>'])
      wf.update(options[:'<id>'], body)
    end

    def extra_validation
      validate_groups
      validate_tokens
      validate_perms
    end

    def validator_exception
      Wavefront::Exception::InvalidServiceAccountId
    end

    private

    def current_state
      wf.describe(options[:'<id>']).response
    end

    def add_priv_to_list(state, priv)
      if state[:groups].include?(priv)
        ok_exit(format("'%<account>s' already has the '%<priv>s' privilege.",
                       account: options[:'<id>'],
                       priv: priv))
      end

      { groups: state[:groups].push(priv), userGroups: user_group_ids(state) }
    end

    def remove_priv_from_list(state, priv)
      unless state[:groups].include?(priv)
        ok_exit(format("'%<account>s' does not have the '%<priv>s' privilege.",
                       account: options[:'<id>'],
                       priv: priv))
      end

      { groups: state[:groups].reject { |g| g == options[:'<privilege>'] },
        userGroups: user_group_ids(state) }
    end

    def add_groups_to_list(state, groups)
      { userGroups: (user_group_ids(state) + groups).uniq }
    end

    def remove_groups_from_list(state, groups)
      { userGroups: (user_group_ids(state) - groups) }
    end

    # The API gives us an array of group objects, but expects back an array
    # only of their IDs
    #
    def user_group_ids(state)
      state[:userGroups].map { |g| g[:id] }
    end

    def active_account?
      !options[:inactive]
    end

    def user_body
      { identifier: options[:'<id>'],
        active: active_account?,
        groups: options[:permission],
        tokens: options[:apitoken],
        userGroups: options[:group] }.tap do |b|
          b[:description] = options[:desc] if options[:desc]
        end
    end

    def item_dump_call
      wf.list.response
    end

    def validate_groups
      options[:group].each { |g| wf_usergroup_id?(g) }
    rescue Wavefront::Exception::InvalidUserGroupId => e
      raise e, 'Invalid usergroup ID'
    end

    def validate_tokens
      options[:apitoken].each { |t| wf_apitoken_id?(t) }
    rescue Wavefront::Exception::InvalidApiTokenId => e
      raise e, 'Invalid API token'
    end

    def validate_perms
      options[:permission].each { |p| wf_permission?(p) }
    rescue Wavefront::Exception::InvalidPermission => e
      raise e, 'Invalid permission'
    end
  end
end
