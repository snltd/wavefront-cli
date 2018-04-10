require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output when writing points directly to
  # Wavefront.
  #
  class Report < Base
    def do_point
      puts 'Point received.' unless options[:quiet]
    end

    def do_file
      do_point
    end
  end
end
