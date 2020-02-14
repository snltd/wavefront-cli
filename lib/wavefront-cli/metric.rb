# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'metric' API. Also includes commands which call
  # the currently unstable 'chart' API.
  #
  class Metric < WavefrontCli::Base
    #
    # There's an extra describe flag that other classes don't have.
    #
    def do_describe
      wf.detail(options[:'<metric>'], options[:glob] || [], options[:offset])
    end

    def do_list_under
      wf_chart_api_object.metrics_under(options[:'<metric>'])
    end

    def do_list_all
      wf_chart_api_object.metrics_under('')
    end

    def extra_validation
      return unless options[:'<metric>']

      begin
        wf_metric_name?(options[:'<metric>'])
      rescue Wavefront::Exception::InvalidMetricName
        abort "'#{options[:'<metric>']}' is not a valid metric ID."
      end
    end

    private

    def wf_chart_api_object
      require 'wavefront-sdk/unstable/chart'
      Wavefront::Unstable::Chart.new(mk_creds, mk_opts)
    end
  end
end
