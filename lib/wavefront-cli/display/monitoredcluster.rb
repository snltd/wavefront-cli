# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for monitored clusters.
  #
  class MonitoredCluster < Base
    def do_list_brief
      multicolumn(:id, :platform, :name)
    end
  end
end
