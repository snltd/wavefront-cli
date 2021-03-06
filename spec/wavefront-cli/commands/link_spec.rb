#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative('../../../lib/wavefront-cli/commands/link')
require_relative 'base_spec'

# Test External Link commands and options
#
class WavefrontCommmandLinkTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandLink.new
    @col_width = 24
  end

  def word
    'ExternalLink'
  end

  def test_word
    assert_equal(wf.word, 'link')
  end
end
