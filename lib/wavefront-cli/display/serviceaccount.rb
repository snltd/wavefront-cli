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

    alias do_join do_groups
    alias do_leave do_groups

    def do_permissions
      if data[:groups].empty?
        puts 'Account does not have any Wavefront permissions.'
      else
        puts data[:groups]
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

    def search_identifier_key
      :identifier
    end

    def priority_keys
      %i[identifier]
    end
  end
end
