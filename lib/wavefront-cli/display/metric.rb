require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for metrics.
  #
  class Metric < Base
    def do_describe
      bail_out if no_data

      @data = data['hosts'].map do |h, _aggr|
        { host: h[:host], last_update: human_time(h[:last_update]) }
      end

      @data.sort_by { |h| h[:last_update] }.reverse

      multicolumn(:host, :last_update)
    end

    def no_data?
      data.empty? || data.hosts.empty?
    end

    def bail_out
      puts 'No matches.'
      exit
    end
  end
end
