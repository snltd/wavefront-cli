require_relative 'base'

module WavefrontOutput
  #
  # Display as a raw Ruby object
  #
  class Ruby < Base
    def run
      p resp
    end
  end
end
