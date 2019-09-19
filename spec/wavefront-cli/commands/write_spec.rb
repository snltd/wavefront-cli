#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test Write commands and options
#
class WavefrontCommmandWriteTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandWrite.new
    @col_width = 25
    @skip_cmd = /write (point|file|distribution)/
  end
end
