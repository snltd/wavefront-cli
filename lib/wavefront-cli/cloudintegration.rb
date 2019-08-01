require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'cloudintegration' API.
  #
  class CloudIntegration < WavefrontCli::Base
    def validator_exception
      Wavefront::Exception::InvalidCloudIntegrationId
    end

    def do_delete
      smart_delete('cloud integration')
    end

    def do_enable
      wf.enable(options[:'<id>'])
    end

    def do_disable
      wf.disable(options[:'<id>'])
    end
  end
end
