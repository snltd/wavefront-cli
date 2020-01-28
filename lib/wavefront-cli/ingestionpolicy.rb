# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the ingestion policy part of the v2 'usage' API.
  #
  class IngestionPolicy < WavefrontCli::Base
    include Wavefront::Mixins

    def do_create
      wf.create(create_body)
    end

    def do_add_user
      account_hook.add_ingestion_policy(options[:'<id>'], options[:'<user>'])
    end

    def do_remove_user
      account_hook.remove_ingestion_policy(options[:'<id>'],
                                           options[:'<user>'])
    end

    def do_members
      resp = do_describe
      resp.response = resp.response[:sampledUserAccounts] +
                      resp.response[:sampledServiceAccounts]
      resp
    end

    def do_for
      resp = do_list
      parent_policies = parent_policies(options[:'<user>'][0],
                                        resp.response.items)
      resp.response = parent_policies.map { |p| p[:id] }
      resp
    end

    private

    def parent_policies(user, items)
      items.select do |p|
        p[:sampledUserAccounts].include?(user) ||
          p[:sampledServiceAccounts].include?(user)
      end
    end

    def create_body
      { name: options[:'<name>'], description: options[:desc] }.compact
    end

    def account_hook
      require 'wavefront-sdk/account'
      Wavefront::Account.new(mk_creds, mk_opts)
    end

    def descriptive_name
      'ingestion policy'
    end

    def validator_exception
      Wavefront::Exception::InvalidIngestionPolicyId
    end
  end
end
