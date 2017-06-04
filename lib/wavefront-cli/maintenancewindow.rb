require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'maintenancewindow' API.
  #
  class MaintenanceWindow < WavefrontCli::Base

    def validator_method
      :wf_maintenance_window_id?
    end

    def validator_exception
      Wavefront::Exception::InvalidMaintenanceWindowId
    end
  end
end
