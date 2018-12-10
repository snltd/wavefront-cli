require 'set'
require 'wavefront-sdk/stdlib/hash'
require_relative 'base'

module WavefrontCsvOutput
  #
  # Display query results in CSV format.
  #
  # The following options are supported:
  #  quote   -- puts all values in soft quotes
  #  headers -- print CSV column headers
  #  tagkeys -- normally point tag keys go in the header and values in
  #             the CSV data. This option puts key=value in the CSV.
  #
  class Query < Base
    attr_reader :columns, :output_opts

    def _run
      @output_opts = extract_output_opts
      data_map = options[:raw] ? raw_output : query_output

      @columns = all_keys(data_map).to_a.flatten.freeze
      csv_headers + csv_body(data_map)
    end

    def raw_output
      resp.each_with_object([]) do |point, a|
        point[:points].each do |p|
          a.<< csv_format(options[:'<metric>'],
                          p[:value],
                          p[:timestamp],
                          options[:host],
                          point[:tags])
        end
      end
    end

    def query_output
      resp[:timeseries].each_with_object([]) do |ts, a|
        ts[:data].each do |point|
          a.<< csv_format(ts[:label],
                          point[1],
                          point[0],
                          ts[:host],
                          ts[:tags])
        end
      end
    end

    def all_keys(data_map)
      data_map.each_with_object(Set.new) { |row, a| a.<< row.keys }
    end

    def csv_headers
      return [] unless output_opts.include?('headers')
      [columns.map { |c| mk_csv_element(c) }.join(',')]
    end

    def csv_body(data_map)
      data_map.map { |r| map_row_to_csv(r) }
    end

    def map_row_to_csv(row)
      columns.map { |col| mk_csv_element(row[col]) }.join(',')
    end

    # Do escaping and quoting
    #
    def mk_csv_element(value)
      if output_opts.include?('quote') || value =~ /[,\s"]/
        quote_value(value)
      else
        value
      end
    end

    def quote_value(value)
      format('"%s"', value.to_s.gsub(/"/, '\"'))
    end

    # Turn a string of output options into an easy-to-query array
    #
    def extract_output_opts
      options[:formatopts].nil? ? [] : options[:formatopts].split(',')
    end

    # Take the data describing a point, and turn it into a CSV row.
    # Tags have their keys removed.
    #
    def csv_format(path, value, timestamp, source, tags = nil)
      ret = { path:      path,
              value:     value,
              timestamp: timestamp,
              source:    source }

      ret.tap { |r| tags.each { |k, v| r[k.to_sym] = tag_val(k, v) } }
    end

    # We may be doing key=val or just val, depending on the formatter options
    #
    def tag_val(key, val)
      output_opts.include?('tagkeys') ? format('%s=%s', key, val) : val
    end
  end
end
