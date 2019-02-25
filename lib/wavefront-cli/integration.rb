require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'integration' API.
  #
  class Integration < WavefrontCli::Base
    def do_status
      wf.status(options[:'<id>'])
    end

    def do_manifests
      if options[:format] == 'human'
        abort 'Human-readable manifest output is not supported.'
      end

      wf.manifests
    end

    def do_install
      wf.install(options[:'<id>'])
    end

    def do_uninstall
      wf.uninstall(options[:'<id>'])
    end

    def do_alert_install
      wf.install_all_alerts(options[:'<id>'])
    end

    def do_alert_uninstall
      wf.uninstall_all_alerts(options[:'<id>'])
    end

    def do_statuses
      wf.statuses
    end

    def do_installed
      wf.installed
    end
  end
end
