# frozen_string_literal: true

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

    def do_awsid_generate
      wf.create_aws_external_id
    end

    def do_awsid_delete
      wf.delete_aws_external_id(options[:'<external_id>'])
    end

    def do_awsid_confirm
      wf.confirm_aws_external_id(options[:'<external_id>'])
    end
  end
end
