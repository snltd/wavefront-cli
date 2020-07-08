# frozen_string_literal: true

require_relative 'base'
require 'wavefront-sdk/apitoken'

module WavefrontCli
  #
  # CLI coverage for the v2 'serviceaccount' API.
  #
  class ServiceAccount < WavefrontCli::Base
    attr_reader :wf_apitoken

    def post_initialize(_options)
      @wf_apitoken = Wavefront::ApiToken.new(mk_creds, mk_opts)
    end

    def do_list
      wf.list
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    alias do_groups do_describe
    alias do_permissions do_describe

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

    def do_delete
      account_hook.delete_accounts(options[:'<account>'])
    end

    def do_leave
      cannot_noop!
      options[:'<group>'].each { |g| wf_usergroup_id?(g) }

      body = remove_groups_from_list(current_state, options[:'<group>'])
      wf.update(options[:'<id>'], body)
    end

    def do_grant
      cannot_noop!
      wf_permission?(options[:'<permission>'])

      body = add_perm_to_list(current_state, options[:'<permission>'])
      wf.update(options[:'<id>'], body)
    end

    def do_revoke
      cannot_noop!
      wf_permission?(options[:'<permission>'])

      body = remove_perm_from_list(current_state, options[:'<permission>'])
      wf.update(options[:'<id>'], body)
    end

    def do_apitoken_list
      wf_apitoken.sa_list(options[:'<id>'])
    end

    def do_apitoken_create
      wf_apitoken.sa_create(options[:'<id>'], options[:name])
    end

    def do_apitoken_delete
      wf_apitoken.sa_delete(options[:'<id>'], options[:'<token_id>'])
    end

    def do_apitoken_rename
      wf_apitoken.sa_rename(options[:'<id>'],
                            options[:'<token_id>'],
                            options[:'<name>'])
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
      resp = wf.describe(options[:'<id>'])

      return resp.response if resp.ok?

      if resp.status.code == 404
        raise WavefrontCli::Exception::UserError,
              "Cannot find service account '#{options[:'<id>']}'"
      end

      raise resp.status.message
    end

    def add_perm_to_list(state, perm)
      if state[:groups].include?(perm)
        ok_exit(format("'%<account>s' already has the '%<perm>s' permission.",
                       account: options[:'<id>'],
                       perm: perm))
      end

      { groups: state[:groups].push(perm), userGroups: user_group_ids(state) }
    end

    def remove_perm_from_list(state, perm)
      unless state[:groups].include?(perm)
        ok_exit(format("'%<account>s' does not have the '%<perm>s' permission.",
                       account: options[:'<id>'],
                       perm: perm))
      end

      { groups: state[:groups].reject { |g| g == options[:'<permission>'] },
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
        tokens: options[:usertoken],
        userGroups: options[:group] }.tap do |b|
          b[:description] = options[:desc] if options[:desc]
        end
    end

    def item_dump_call
      wf.list.response
    end

    def validate_groups
      options[:group].each { |g| wf_usergroup_id?(g) }
    end

    def validate_tokens
      options[:usertoken].each { |t| wf_apitoken_id?(t) }
    end

    def validate_perms
      options[:permission].each { |p| wf_permission?(p) }
    end

    def descriptive_name
      'service account'
    end

    def account_hook
      require 'wavefront-sdk/account'
      Wavefront::Account.new(mk_creds, mk_opts)
    end
  end
end
