require_relative 'base'

module WavefrontOutput
  #
  # Display as JSON
  #
  class Json < Base
    def _run
      resp.to_json
    end
  end
end
