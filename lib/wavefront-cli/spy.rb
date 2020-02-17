# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # Spy on metrics being ingested into Wavefront
  #
  class Spy < Base
    def no_api_response
      %w[do_points do_histograms do_spans do_ids]
    end

    def do_points
      wf.points(rate, fn_args, fn_opts)
    end

    def do_histograms
      wf.histograms(rate, fn_args, fn_opts)
    end

    def do_spans
      wf.spans(rate, fn_args, fn_opts)
    end

    def do_ids
      wf.ids(rate,
             { prefix: options[:prefix], type: options[:type] },
             fn_opts)
    end

    # Passing an empty array to the Spy methods sets up a filter for things
    # with an empty tag key. So we won't.
    #
    def key_opts
      options[:tagkey].empty? ? nil : options[:tagkey]
    end

    def display_class
      'WavefrontDisplay::Spy'
    end

    private

    def require_sdk_class
      require 'wavefront-sdk/unstable/spy'
    end

    def _sdk_class
      'Wavefront::Unstable::Spy'
    end

    def rate
      return 0.01 unless options[:rate]

      options[:rate].to_f
    end

    def fn_args
      { prefix: options[:prefix],
        host: options[:host],
        tag_key: key_opts }
    end

    def fn_opts
      { timestamp_chunks: options[:timestamp],
        timeout: options[:endafter].to_i }
    end
  end
end
