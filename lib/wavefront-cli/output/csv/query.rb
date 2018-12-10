require 'wavefront-sdk/stdlib/hash'
require_relative 'base'

module WavefrontCsvOutput
  #
  # Display query results in Wavefront wire format. We have to
  # handle raw and normal output in different ways.
  #
  class Query < Base
    def _run
      if options[:raw]
        raw_output
      else
        query_output
      end
    end

    def raw_output
      puts "printing raw csv"
      return
      resp.each_with_object('') do |point, a|
        point[:points].each do |p|
          a.<< wavefront_format(options[:'<metric>'],
                                p[:value],
                                p[:timestamp],
                                options[:host],
                                point[:tags]) + "\n"
        end
      end
    end

    def query_output
      puts "printing query csv"
      return
      resp[:timeseries].each_with_object('') do |ts, a|
        ts[:data].each do |point|
          a.<< wavefront_format(ts[:label],
                                point[1],
                                point[0],
                                ts[:host],
                                ts[:tags]) + "\n"
        end
      end
    end

    def wavefront_format(path, value, timestamp, source, tags = nil)
      arr = [path, value, timestamp, format('source=%s', source)]
      arr.<< tags.to_wf_tag if tags && !tags.empty?
      arr.join(' ')
    end
  end
end
