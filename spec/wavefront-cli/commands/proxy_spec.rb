#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test Proxy commands and options
#
class WavefrontCommmandProxyTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandProxy.new
    @col_width = 22
  end
end
