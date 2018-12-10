module WavefrontCsvOutput
  #
  # Standard output template
  #
  class Base
    attr_reader :resp, :options

    def initialize(resp, options)
      @resp = resp
      @options = options
    end

    def run
      puts _run
    end
  end
end
