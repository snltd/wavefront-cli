#!/usr/bin/env ruby

require 'pathname'
word = Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')
require_relative('../../../lib/wavefront-cli/commands/link')
require_relative './base_spec'

class WavefrontCommmandLinkTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandLink.new
    @col_width = 19
  end

  def word
    'ExternalLink'
  end

  def test_word
    assert_equal(wf.word, 'link')
  end
end
