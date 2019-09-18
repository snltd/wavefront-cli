# frozen_string_literal: true

require_relative 'base'
require_relative 'printer/sparkline'

module WavefrontDisplay
  #
  # Format human-readable output for queries.
  #
  class Query < Base
    # rubocop:disable Metrics/AbcSize
    def do_default
      d_obj = { name: data.name,
                query: data.query,
                timeseries: mk_timeseries(data),
                events: mk_events(data) }

      if data.key?(:warnings) && !options[:nowarn]
        d_obj[:warnings] = data[:warnings]
      end

      @data = d_obj
      long_output
    rescue StandardError
      raise(WavefrontCli::Exception::InvalidQuery,
            data[:errorMessage].split("\n").first)
    end
    # rubocop:enable Metrics/AbcSize

    # Prioritizing keys does not make sense in this context
    #
    def prioritize_keys(data, _keys)
      data
    end

    def mk_timeseries(data)
      return [] unless data.key?(:timeseries)

      data[:timeseries].each do |s|
        unless options[:nospark]
          s[:sparkline] = WavefrontSparkline.new(s[:data]).sparkline
          s.reorder!(label: nil, sparkline: nil)
        end

        s[:data] = humanize_series(s[:data])
      end
    end

    def mk_events(data)
      return [] unless data.key?(:events)

      data[:events].map { |s| humanize_event(s) }
    end

    def do_run
      do_default
    end

    def do_raw
      data.each { |ts| puts humanize_series(ts[:points]).join("\n") }
    end

    def do_raw_404
      puts 'API 404: metric does not exist.'
    end

    def do_aliases
      if data.empty?
        puts 'No aliases defined.'
      else
        data.each_key { |k| puts k.to_s[2..-1] }
      end
    end

    private

    def humanize_event(data)
      data[:start] = human_time(data[:start])
      data[:end] = human_time(data[:end]) if data[:end]
      data.delete(:isEphemeral)
      data
    end

    # rubocop:disable Metrics/MethodLength
    def humanize_series(data)
      last_date = nil

      data.map! do |row|
        if row.is_a?(Hash)
          ht = human_time(row[:timestamp])
          val = row[:value]
        else
          ht = human_time(row[0])
          val = row[1]
        end

        date, time = ht.split
        ds = date == last_date ? '' : date
        last_date = date
        format('%-12s %s    %s', ds, time, val)
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
