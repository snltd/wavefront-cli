# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # The spy commands stream directly to stdout, so nothing needs to be done
  # here. The methods have to be stubbed to avoid errors.
  #
  class Spy < Base
    def do_points; end

    def do_histograms; end

    def do_spans; end

    def do_ids; end
  end
end
