# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'maintenancewindow' API.
  #
  class MaintenanceWindow < WavefrontCli::Base
    include Wavefront::Mixins

    def validator_method
      :wf_maintenance_window_id?
    end

    def validator_exception
      Wavefront::Exception::InvalidMaintenanceWindowId
    end

    def do_create
      body = build_body

      [%i[CustomerTags atag], %i[HostTags htag],
       %i[HostNames host]].each do |key, opt|
        k = ('relevant' + key.to_s).to_sym
        body[k] = options[opt] unless options[opt].empty?
      end

      wf.create(body)
    end

    def build_body
      ret = { title: options[:'<title>'],
              startTimeInSeconds: window_start,
              endTimeInSeconds: window_end }

      ret[:reason] = options[:desc] if options[:desc]
      ret
    end

    # @return [Integer] start time of window, in seconds. If not
    #   given as an option, start it now
    #
    def window_start
      if options[:start]
        parse_time(options[:start])
      else
        Time.now.to_i
      end
    end

    # @return [Integer] end time of window, in seconds. If not
    #   given as an option, end it in an hour
    #
    def window_end
      if options[:end]
        parse_time(options[:end])
      else
        window_start + 3600
      end
    end

    def do_extend_by
      cannot_noop!
      to_add = parse_range_to_add
      old_end = wf.describe(options[:'<id>']).response.endTimeInSeconds
      change_end_time(old_end + to_add)
    end

    def parse_range_to_add
      options[:'<time>'].to_seconds
    rescue ArgumentError
      abort "Could not parse time range '#{options[:'<time>']}'."
    end

    def do_extend_to
      cannot_noop!
      change_end_time(parse_time(options[:'<time>']))
    end

    def do_close
      cannot_noop!
      change_end_time(Time.now.to_i)
    end

    def change_end_time(timestamp)
      wf.update(options[:'<id>'], endTimeInSeconds: timestamp)
    end

    def do_ongoing
      ret = wf.ongoing

      exit if options[:noop]

      return ret unless ret.is_a?(Wavefront::Response) && ret.empty?

      ok_exit('No maintenance windows currently ongoing.')
    end

    def do_pending
      range = options[:'<hours>'].to_f
      range = 24 unless range.positive?

      ret = wf.pending(range)

      exit if options[:noop]

      return ret unless ret.is_a?(Wavefront::Response) && ret.empty?

      ok_exit(format('No maintenance windows in the next %<range>s hours.',
                     range: range))
    end
  end
end
