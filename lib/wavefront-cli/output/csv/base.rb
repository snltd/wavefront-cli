module WavefrontCsvOutput
  #
  # Standard output template
  #
  class Base
    attr_reader :resp, :options, :headers

    def initialize(resp, options)
      @resp = resp
      @options = options
      @headers = []
    end

    def run
      puts _run
    end
  end
end
