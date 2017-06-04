require_relative './base'

module WavefrontCli

  # CLI coverage for the v2 'externallink' API.
  #
  class ExternalLink < WavefrontCli::Base

    def validator_method
      :wf_link_id?
    end

    def validator_exception
      Wavefront::Exception::InvalidExternalLinkId
    end
  end
end
