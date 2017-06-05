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
  end
end
