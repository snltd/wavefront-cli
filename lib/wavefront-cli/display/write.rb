require_relative 'base'

module WavefrontDisplay
  # Format human-readable output when writing points.
  #
  class Write < Base
    # rubocop:disable Metrics/AbcSize
    def do_point
      unless options[:quiet] || (data[:unsent] + data[:rejected].positive?)
        report
      end
      exit(data.rejected.zero? && data.unsent.zero? ? 0 : 1)
    end
    # rubocop:enable Metrics/AbcSize

    def do_file
      do_point
    end

    def report
      %i[sent rejected unsent].each do |k|
        puts format('  %12s %d', k.to_s, data[k])
      end
    end
  end
end
