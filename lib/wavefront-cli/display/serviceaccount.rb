# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for service account commands.
  #
  class ServiceAccount < Base
    def do_describe
      long_output
    end

    def do_list_brief
      if data.empty?
        puts 'You have no service accounts.'
      else
        multicolumn(:identifier, :description)
      end
    end

    def do_activate
      puts format("Activated service account '#{options[:'<id>']}'.")
    end

    def do_deactivate
      puts format("Deactivated service account '#{options[:'<id>']}'.")
    end

    def do_groups
      if data[:userGroups].empty?
        puts 'Account does not belong to any groups.'
      else
        data[:userGroups].each { |u| puts format('%<id>s (%<name>s)', u) }
      end
    end

    def do_roles
      if data[:roles].empty?
        puts 'Account does not have any roles attached.'
      else
        data[:roles].each { |r| puts format('%<id>s (%<name>s)', r) }
      end
    end

    alias do_join do_groups
    alias do_leave do_groups

    def do_ingestionpolicy
      if data[:ingestionPolicy].empty?
        puts 'Account does not have an ingestion policy attached.'
      else
        puts format('%<id>s (%<name>s)', data[:ingestionPolicy])
      end
    end

    def do_grant
      puts format("Granted '%<perm>s' to '%<account>s'.",
                  perm: options[:'<permission>'], account: options[:'<id>'])
    end

    def do_revoke
      puts format("Revoked '%<perm>s' from '%<account>s'.",
                  perm: options[:'<permission>'], account: options[:'<id>'])
    end

    def do_apitoken_list
      if data.empty?
        puts 'Account does not have any API tokens.'
      else
        multicolumn(:tokenID, :tokenName)
      end
    end

    def do_apitoken_delete
      puts format("Deleted API token '#{options[:'<token_id>']}'.")
    end

    def do_delete
      puts format("Deleted #{friendly_name} %<quoted_account>s.",
                  quoted_account: quoted(options[:'<account>']))
    end

    def search_identifier_key
      :identifier
    end

    def priority_keys
      %i[identifier]
    end
  end
end
