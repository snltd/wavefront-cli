#!/usr/bin/env ruby

require 'pathname'
word = Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')
require_relative('../../../lib/wavefront-cli/commands/window')
require_relative './base_spec'

class WavefrontCommmandWindowTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandWindow.new
    @col_width = 19
  end

  def word
    'MaintenanceWindow'
  end

  def test_word
    assert_equal(wf.word, 'window')
  end
end
