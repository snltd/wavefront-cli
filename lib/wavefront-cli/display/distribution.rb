# frozen_string_literal: true

require_relative 'write'

module WavefrontDisplay
  # Format human-readable output when writing distributions
  #
  class Distribution < Write
    def do_distribution
      print_report unless options[:quiet]
      exit(data.rejected.zero? && data.unsent.zero? ? 0 : 1)
    end

    def print_report
      report unless (data[:unsent] + data[:rejected]).positive?
    end
  end
end
