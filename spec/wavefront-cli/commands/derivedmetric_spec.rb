#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test derived metric commands and options
#
class WavefrontCommmandDerivedMetricTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandDerivedmetric.new
    @col_width = 22
  end
end
