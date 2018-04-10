require_relative 'base'

module WavefrontOutput
  #
  # Display as JSON
  #
  class Json < Base
    def run
      puts resp.to_json
    end
  end
end
