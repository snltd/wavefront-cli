require_relative './base'

module WavefrontDisplay

  # Format human-readable output for queries.
  #
  class Query < Base
    def do_default
      last_date = nil

      ts = data.timeseries.each do |s|
        s[:data].map! do |t, v|
          ht = human_time(t)
          time, date = ht.split
          ht = ht.split.first if date == last_date
          last_date = date
          format("%-25s %s", ht, v)
        end
      end

      new = {
        name: data.name,
        query: data.query,
        timeseries: ts
      }

      @data = new
      long_output
    end

    def do_raw
      data.each do |ts|
        last_date = nil
        ts[:points].each do |row|
          ht = human_time(row[:timestamp])
          time, date = ht.split
          ht = ht.split.first if date == last_date
          last_date = date
          puts format("%-25s %s", ht, row[:value])
        end
      end
    end
  end
end
