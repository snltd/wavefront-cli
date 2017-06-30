#!/usr/bin/env ruby

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative './base_spec'

# Test Event commands and options
#
class WavefrontCommmandEventTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandEvent.new
    @col_width = 23
    @skip_cmd = /event show/
  end
end
