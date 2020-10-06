# frozen_string_literal: true

require_relative 'base'
require_relative 'printer/sparkline'

module WavefrontDisplay
  #
  # Format human-readable output for queries.
  #
  class Query < Base
    def do_default
      @data = default_data_object
      long_output
    rescue StandardError
      raise(WavefrontCli::Exception::InvalidQuery,
            data[:errorMessage].split("\n").first)
    end

    # rubocop:disable Metrics/AbcSize
    def default_data_object
      { name: data.name,
        query: data.query,
        timeseries: mk_timeseries(data),
        traces: mk_traces(data),
        spans: mk_spans(data),
        events: mk_events(data) }.tap do |d|
          d[:warnings] = data[:warnings] if show_warnings?
        end
    end
    # rubocop:enable Metrics/AbcSize

    def show_warnings?
      data.key?(:warnings) && !options[:nowarn]
    end

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

    def mk_traces(data)
      return [] unless data.key?(:traces)

      data[:traces].map { |t| humanize_trace(t) }
    end

    def mk_spans(data)
      return [] unless data.key?(:spans)

      data[:spans].map { |t| humanize_span(t) }
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

    # Prepare a padded line with the timestamp and value. If it's the
    # @return [String]
    #
    def humanize_series(data)
      last_date = nil

      data.map do |row|
        ht, val = row_time_and_val(row)
        date, time = ht.split
        date_string = date == last_date ? '' : date
        last_date = date
        format('%-12<series>s %<time>s    %<value>s',
               series: date_string, time: time, value: val)
      end
    end

    def humanize_trace(data)
      @printer_opts[:sep_depth] = 3

      data.tap do |t|
        t[:start] = human_time(t[:start_ms])
        t[:end] = human_time(t[:end_ms])
        t.delete(:start_ms)
        t.delete(:end_ms)
        t.delete(:startMs)
        t.spans = t.spans.map { |s| humanize_trace_span(s) }
      end
    end

    def humanize_span(data)
      @printer_opts[:sep_depth] = 2
      data
    end

    def humanize_trace_span(span)
      span.tap do |s|
        s[:startMs] = human_time(s[:startMs])
      end
    end

    def row_time_and_val(row)
      if row.is_a?(Hash)
        [human_time(row[:timestamp]), row[:value]]
      else
        [human_time(row[0]), row[1]]
      end
    end
  end
end
