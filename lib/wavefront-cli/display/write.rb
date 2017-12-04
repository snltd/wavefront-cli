require_relative './base'

module WavefrontDisplay
  # Format human-readable output when writing points.
  #
  class Write < Base
    def do_point
      %i[sent rejected unsent].each do |k|
        puts format('  %12s %d', k.to_s, data[k])
      end

      exit(data.rejected.zero? && data.unsent.zero? ? 0 : 1)
    end

    def do_file
      do_point
    end
  end
end
