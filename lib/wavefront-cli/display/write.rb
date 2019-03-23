require_relative 'base'

module WavefrontDisplay
  # Format human-readable output when writing points.
  # In this context data is a Hash of the form
  # { sent: 1, rejected: 0, unsent: 0 }
  #
  class Write < Base
    attr_reader :not_sent

    def do_point
      @not_sent = data['rejected'] + data['unsent']
      report unless nothing_to_say?
      exit not_sent.zero? ? 0 : 1
    end

    def nothing_to_say?
      options[:quiet] || not_sent.positive?
    end

    def do_file
      do_point
    end

    def report
      %w[sent rejected unsent].each do |k|
        puts format('  %12s %d', k.to_s, data[k])
      end
    end
  end
end
