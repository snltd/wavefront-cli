#!/usr/bin/env ruby

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative './base_spec'

# Test Alert commands and options
#
class WavefrontCommmandAlertTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandAlert.new
    @col_width = 21
  end
end
