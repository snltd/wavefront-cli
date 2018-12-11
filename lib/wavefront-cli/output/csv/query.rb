require 'set'
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
    attr_reader :columns, :formatopts, :headers, :data_map

    def _run
      csv_headers + csv_body
    end

    def post_initialize
      @headers = []
      @formatopts = extract_formatopts
      @data_map    = options[:raw] ? raw_output : query_output
      @columns     = all_keys.freeze
    end

    # @return [Array[Hash]] which goes in the @data_map
    #
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

    # @return [Array[Hash]] which goes in the @data_map
    #
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

    # @return [Array] unique list of all keys in an array of hashes
    #
    def all_keys(data = data_map)
      data.each_with_object(Set.new) { |row, a| a.merge(row.keys) }.to_a
    end

    # @return [Array] single element of comma-separated CSV column
    #   headers if requested, otherwise []
    #
    def csv_headers
      return [] unless formatopts.include?('headers')
      [columns.map { |c| csv_value(c) }.join(',')]
    end

    def csv_body
      data_map.map { |r| map_row_to_csv(r) }
    end

    def map_row_to_csv(row)
      columns.map { |col| csv_value(row[col]) }.join(',')
    end

    # Do escaping and quoting
    #
    def csv_value(value)
      if (formatopts.include?('quote') || value =~ /[,\s"]/) &&
         !value.to_s.empty?
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
    def extract_formatopts
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
      formatopts.include?('tagkeys') ? format('%s=%s', key, val) : val
    end
  end
end
