#!/usr/bin/env ruby

require_relative('../../../lib/wavefront-cli/commands/cloudintegration')
require_relative './base_spec'

# Test Cloud Integration commands and options
#
class WavefrontCommmandCloudIntegrationTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandCloudintegration.new
    @col_width = 19
  end

  def word
    'CloudIntegration'
  end

  def test_word
    assert_equal(wf.word, 'cloudintegration')
  end
end
