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
      multicolumn(:identifier, :description)
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

    def do_privileges
      if data[:groups].empty?
        puts 'Account does not have any Wavefront privileges.'
      else
        puts data[:groups]
      end
    end

    alias do_grant do_privileges
    alias do_revoke do_privileges

    def do_apitoken_list
      if data.empty?
        puts 'Account does not have any tokens.'
      else
        multicolumn(:tokenID, :tokenName)
      end
    end

    def search_identifier_key
      :identifier
    end
  end
end
