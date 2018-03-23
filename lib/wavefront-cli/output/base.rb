module WavefrontOutput
  class Base
    attr_reader :resp, :options

    def initialize(resp, options)
      @resp = resp
      @options = options
    end
  end
end
