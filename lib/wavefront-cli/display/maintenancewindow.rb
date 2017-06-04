require_relative './base'

module WavefrontDisplay

  # Format human-readable output for maintenance windows.
  #
  class MaintenanceWindow < Base
    def do_import
      puts "Imported maintenance window."
      long_output
    end

    def do_list_brief
      terse_output(:id, :title)
    end

    def do_delete
      puts "Deleted maintenance window '#{options[:'<id>']}'."
    end
  end
end
