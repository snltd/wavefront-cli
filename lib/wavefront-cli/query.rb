require 'wavefront-sdk/mixins'
require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'query' API.
  #
  class Query < WavefrontCli::Base
    include Wavefront::Mixins

    def do_default
      opts = {
        autoEvents:             options[:events],
        i:                      options[:inclusive],
        summarization:          options[:summarize] || 'mean',
        listMode:               true,
        strict:                 true,
        includeObsoleteMetrics: options[:obsolete],
        sorted:                 true
      }

      if options[:start]
        options[:start] = parse_time(options[:start], true)
      else
        options[:start] = (Time.now - 600).to_i
      end

      if options[:end]
        options[:end] = parse_time(options[:end], true)
        t_end = options[:end]
      else
        t_end = Time.now.to_i
      end

      options[:granularity] ||= default_granularity((t_end -
                                                    options[:start]).to_i)

      opts[:n] = options[:name] if options[:name]
      opts[:p] = options[:points] if options[:points]

      wf.query(options[:'<query>'], options[:granularity],
               options[:start], options[:end] || nil, opts)
    end


    # Work out a sensible granularity based on the time window
    #
    def default_granularity(window)
      if window < 300
        :s
      elsif window < 10800
        :m
      elsif window < 259200
        :h
      else
        :d
      end
    end

    def extra_validation
      return unless options[:granularity]
      begin
        wf_granularity?(options[:granularity])
      rescue Wavefront::Exception::InvalidGranularity
        abort "'#{options[:granularity]}' is not a valid granularity."
      end
    end

    def do_raw
      wf.raw(options[:'<metric>'], options[:host], options[:start],
             options[:end])
    end
  end
end
