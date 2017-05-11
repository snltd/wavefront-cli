require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'maintenancewindow' API.
  #
  class MaintenanceWindow < WavefrontCli::Base
    def do_list
      @verbose_response = true
      @col2 = 'title'
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end
  end
end
