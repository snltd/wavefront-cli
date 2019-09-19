# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for integrations.
  #
  class Integration < Base
    def do_list_brief
      multicolumn(:id, :name, :description)
    end

    def do_installed
      multicolumn(:id, :name, :description)
    end

    def do_install_all_alerts
      puts "Installed alerts for #{options[:'<id>']}."
    end

    def do_uninstall_all_alerts
      puts "Uninstalled alerts for #{options[:'<id>']}."
    end
  end
end
