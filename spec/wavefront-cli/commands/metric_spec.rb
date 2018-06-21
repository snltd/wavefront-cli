#!/usr/bin/env ruby

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test Metric commands and options
#
class WavefrontCommmandMetricTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandMetric.new
    @col_width = 19
  end
end
