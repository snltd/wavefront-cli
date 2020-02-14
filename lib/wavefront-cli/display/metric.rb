# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for metrics.
  #
  class Metric < Base
    def do_describe
      bail_out if no_data?

      @data = data['hosts'].map do |h, _aggr|
        { host: h[:host], last_update: human_time(h[:last_update]) }
      end

      @data.sort_by { |h| h[:last_update] }.reverse

      multicolumn(:host, :last_update)
    end

    def do_list_under
      bail_out if data.empty?

      puts data.sort
    end

    alias do_list_all do_list_under

    def no_data?
      data.empty? || data.hosts.empty?
    end

    def bail_out
      puts "Did not find metric '#{options[:'<metric>']}'."
      exit
    end
  end
end
