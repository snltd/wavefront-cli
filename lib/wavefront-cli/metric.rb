require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'metric' API.
  #
  class Metric < WavefrontCli::Base
    def do_describe
      @response = :raw

      wf.detail(options[:'<metric>'], options[:glob] || [],
                options[:offset])
    end
  end
end
