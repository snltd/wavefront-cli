#!/usr/bin/env ruby

require 'pathname'
word = Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')
require_relative('../../../lib/wavefront-cli/commands/integration')
require_relative './base_spec'

class WavefrontCommmandIntegrationTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandIntegration.new
    @col_width = 19
  end

  def word
    'CloudIntegration'
  end

  def test_word
    assert_equal(wf.word, 'integration')
  end
end
