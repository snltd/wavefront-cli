require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'metric' API.
  #
  class Metric < WavefrontCli::Base
    def do_describe
      @response = :raw
      wf.detail(options[:'<metric>'], options[:glob] || [], options[:offset])
    end

    def extra_validation
      return unless options[:'<metric>']
      begin
        wf_metric_name?(options[:'<metric>'])
      rescue Wavefront::Exception::InvalidMetricName
        abort "'#{options[:'<metric>']}' is not a valid metric."
      end
    end
  end
end
