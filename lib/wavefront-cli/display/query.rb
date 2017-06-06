require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for queries.
  #
  class Query < Base
    def do_default
      ts = data.timeseries.each { |s| s[:data] = humanize_series(s[:data]) }

      new = {
        name: data.name,
        query: data.query,
        timeseries: ts
      }

      @data = new
      long_output
    end

    def do_raw
      data.each { |ts| puts humanize_series(ts[:points]).join("\n") }
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
        format('%12s %s    %s', ds, time, val)
      end
    end
  end
end
