require 'wavefront-sdk/stdlib/hash'
require_relative 'base'

module WavefrontWavefrontOutput
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

    def wavefront_format(path, value, ts, source, tags = nil)
      arr = [path, value, ts, format('source=%s', source)]
      arr.<< tags.to_wf_tag if tags && !tags.empty?
      arr.join(' ')
    end
  end
end
