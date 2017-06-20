require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for metrics.
  #
  class Metric < Base
    def do_describe
      if data.hosts.empty?
        puts "No matches."
        exit
      end

      modified_data = data['hosts'].map do |h, aggr|
        { host:        h[:host],
          last_update: human_time(h[:last_update]) }
      end.sort_by{ |h| h[:last_update] }.reverse

      terse_output(:host, :last_update, modified_data)
    end
  end
end
