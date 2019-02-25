#!/usr/bin/env ruby

require_relative('../../../lib/wavefront-cli/commands/window')
require_relative 'base_spec'

# Test Maintenance Window commands and options
#
class WavefrontCommmandWindowTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandWindow.new
    @col_width = 22
  end

  def word
    'MaintenanceWindow'
  end

  def test_word
    assert_equal(wf.word, 'window')
  end
end
