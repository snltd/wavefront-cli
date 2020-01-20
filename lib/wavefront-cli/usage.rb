# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for part of the v2 'usage' API. The rest is in the
  # 'ingestionpolicy' command.
  #
  class Usage < WavefrontCli::Base
    include Wavefront::Mixins

    def do_export_csv
      t_start = options[:start] ? parse_time(options[:start]) : default_start
      t_end = options[:end] ? parse_time(options[:end]) : nil
      wf.export_csv(t_start, t_end)
    end

    def default_start
      parse_time(Time.now - 60 * 60 * 24)
    end
  end
end
