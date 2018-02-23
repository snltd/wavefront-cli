require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for queries.
  #
  class Query < Base
    def do_default
      ts = if data.key?(:timeseries)
             data[:timeseries].each do |s|
               s[:data] = humanize_series(s[:data])
             end
           else
             []
           end

      events = if data.key?(:events)
                 data[:events].map { |s| humanize_event(s) }
               else
                 []
               end

      new = { name:       data.name,
              query:      data.query,
              timeseries: ts,
              events:     events }

      @data = new
      long_output
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
        data.each { |k, _v| puts k.to_s[2..-1] }
      end
    end

    private

    def humanize_event(data)
      data[:start] = human_time(data[:start])
      data[:end] = human_time(data[:end]) if data[:end]
      data.delete(:isEphemeral)
      data
    end

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
    end
  end
end
