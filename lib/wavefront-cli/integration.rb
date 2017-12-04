require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'integration' API.
  #
  class Integration < WavefrontCli::Base
    def do_status
      wf.status(options[:'<id>'])
    end

    def do_manifests
      wf.manifests
    end

    def do_install
      wf.install(options[:'<id>'])
    end

    def do_uninstall
      wf.uninstall(options[:'<id>'])
    end

    def do_statuses
      wf.statuses
    end
  end
end
