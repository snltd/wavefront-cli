require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for metrics.
  #
  class Metric < Base
    def do_describe
      if data.empty? || data.hosts.empty?
        puts 'No matches.'
        exit
      end

      @data = data['hosts'].map do |h, _aggr|
        { host: h[:host], last_update: human_time(h[:last_update]) }
      end.sort_by { |h| h[:last_update] }.reverse

      multicolumn(:host, :last_update)
    end
  end
end
