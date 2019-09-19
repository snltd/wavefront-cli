#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test Message commands and options
#
class WavefrontCommmandMessageTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandMessage.new
    @col_width = 22
  end
end
