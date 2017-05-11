require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'query' API.
  #
  class Query < WavefrontCli::Base
    def do_default
      @response = :raw

      opts = {
        autoEvents:             options[:events],
        i:                      options[:inclusive],
        summarization:          options[:summarize] || 'mean',
        listMode:               true,
        strict:                 false,
        includeObsoleteMetrics: options[:obsolete],
        sorted:                 true
      }

      opts[:n] = options[:name] if options[:name]
      opts[:p] = options[:points] if options[:points]

      wf.query(options[:'<query>'], options[:granularity],
               options[:start], options[:end] || nil, opts)
    end

    def do_raw
      @response = :raw
      wf.raw(options[:'<metric>'], options[:host], options[:start],
             options[:end])
    end
  end
end
