# frozen_string_literal: true

require_relative 'base'

module WavefrontOutput
  #
  # Display query results in native Wavefront format. The idea is
  # that timeseries can be extracted, modified, and fed back in via
  # a proxy.
  #
  class Wavefront < Base; end
end
