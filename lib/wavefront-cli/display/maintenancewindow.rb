require_relative './base'

module WavefrontDisplay

  # Format human-readable output for maintenance windows.
  #
  class MaintenanceWindow < Base
    def do_list_brief
      terse_output(:id, :title)
    end
  end
end
