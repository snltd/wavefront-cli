require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for cloud integrations.
  #
  class CloudIntegration < Base
    def do_list_brief
      terse_output(:id, :service)
    end
  end
end
