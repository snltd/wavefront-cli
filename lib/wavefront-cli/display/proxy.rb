# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for proxies.
  #
  class Proxy < Base
    def do_list
      filter_inactive_proxies! if options[:active]
      super
    end

    def do_list_brief
      filter_inactive_proxies! if options[:active]
      super
    end

    def do_describe
      readable_time(:lastCheckInTime)
      long_output
    end

    def do_versions
      multicolumn(:id, :version, :name)
    end

    def do_shutdown
      puts "Requested shutdown of proxy '#{options[:'<id>']}'."
    end

    private

    def filter_inactive_proxies!
      data.delete_if { |p| p[:status] != 'ACTIVE' }
    end
  end
end
