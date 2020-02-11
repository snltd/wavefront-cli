# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # Spy on metrics being ingested into Wavefront
  #
  class Spy < Base

    def do_points
      pp options
      wf.points(options[:rate] || 0.01,
                { prefix: options[:prefix],
                  host: options[:host],
                  tag_key: options[:tagkey] },
               )
    end

    private

    def require_sdk_class
      require 'wavefront-sdk/unstable/spy'
    end

    def _sdk_class
      'Wavefront::Unstable::Spy'
    end
  end
end
