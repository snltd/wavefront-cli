require 'wavefront-sdk/mixins'
require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'query' API.
  #
  class Query < WavefrontCli::Base
    attr_reader :query_string

    include Wavefront::Mixins

    def no_api_response
      %w[do_aliases]
    end

    def do_default
      qs = query_string || options[:'<query>']

      t_start     = window_start
      t_end       = window_end
      granularity = granularity(t_start, t_end)
      t_end       = nil unless options[:end]

      wf.query(qs, granularity, t_start, t_end, q_opts)
    end

    def do_raw
      wf.raw(options[:'<metric>'], options[:host], options[:start],
             options[:end])
    end

    def do_run
      alias_key = format('q_%s', options[:'<alias>']).to_sym
      query = all_aliases.fetch(alias_key, nil)

      unless query
        abort "Query not found. 'wf query aliases' will show all " \
              'aliased queries.'
      end

      @query_string = query
      do_default
    end

    def do_aliases
      all_aliases
    end

    private

    # @return [Hash] options for the SDK query method
    #
    # rubocop:disable Metrics/AbcSize
    def q_opts
      ret = { autoEvents:             options[:events],
              i:                      options[:inclusive],
              summarization:          options[:summarize] || 'mean',
              listMode:               true,
              strict:                 true,
              includeObsoleteMetrics: options[:obsolete],
              sorted:                 true }

      ret[:n] = options[:name] if options[:name]
      ret[:p] = options[:points] if options[:points]
      ret
    end
    # rubocop:enable Metrics/AbcSize

    # @return [Integer] start of query window. If one has been
    #   given, that; if not, ten minutes ago
    #
    def window_start
      if options[:start]
        parse_time(options[:start], true)
      else
        (Time.now - 600).to_i
      end
    end

    # @return [Integer] end of query window. If one has been
    #   given, that; if not, now
    #
    def window_end
      if options[:end]
        parse_time(options[:end], true)
      else
        Time.now.to_i
      end
    end

    def granularity(t_start, t_end)
      options[:granularity] || default_granularity(t_start - t_end)
    end

    # Work out a sensible granularity based on the time window
    #
    def default_granularity(window)
      if window < 300
        :s
      elsif window < 10_800
        :m
      elsif window < 259_200
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

    # @return [Hash] all query aliases for the active profile
    #
    def all_aliases
      WavefrontCli::OptHandler.new(options).opts.select do |line|
        line.to_s.start_with?('q_')
      end
    end
  end
end
