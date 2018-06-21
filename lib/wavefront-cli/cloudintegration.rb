require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'cloudintegration' API.
  #
  class CloudIntegration < WavefrontCli::Base
    def validator_exception
      Wavefront::Exception::InvalidCloudIntegrationId
    end
  end
end
