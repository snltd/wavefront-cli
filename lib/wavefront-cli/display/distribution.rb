require_relative 'write'

module WavefrontDisplay
  # Format human-readable output when writing distributions
  #
  class Distribution < Write
    # rubocop:disable Metrics/AbcSize
    def do_distribution
      report unless options[:quiet] || (data[:unsent] + data[:rejected] > 0)
      exit(data.rejected.zero? && data.unsent.zero? ? 0 : 1)
    end
    # rubocop:enable Metrics/AbcSize
  end
end
