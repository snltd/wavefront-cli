# frozen_string_literal: true

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

      raise unless not_sent.zero?
    end

    def nothing_to_say?
      options[:quiet] || not_sent.positive?
    end

    def do_file
      do_point
    end

    def report
      %w[sent rejected unsent].each do |status|
        puts format('  %12<status>s %<count>d',
                    status: status,
                    count: data[status])
      end
    end
  end
end
