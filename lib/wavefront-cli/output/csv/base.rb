module WavefrontCsvOutput
  #
  # Standard output template
  #
  class Base
    attr_reader :resp, :options

    def initialize(resp, options)
      @resp        = resp
      @options     = options
      post_initialize if respond_to?(:post_initialize)
    end

    def run
      puts _run
    end
  end
end
