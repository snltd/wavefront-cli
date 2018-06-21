#!/usr/bin/env ruby

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test Query commands and options
#
class WavefrontCommmandQueryTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandQuery.new
    @col_width = 24
    @skip_cmd = /aliases/
  end
end
