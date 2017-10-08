#!/usr/bin/env ruby

require_relative '../../../../lib/wavefront-cli/display/printer/base'
require_relative '../spec_helper'

# Test base class
#
class WavefrontDisplayPrinterBase < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplayPrinter::Base.new
  end

  def test_key_width
    assert_equal(wf.key_width, 0)
    assert_equal(wf.key_width(key1: 1, row2: 2, longrow: 3), 10)
    assert_equal(wf.key_width({ key1: 1, row2: 2, longrow: 3 }, 3), 10)
  end
end
