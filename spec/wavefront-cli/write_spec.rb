#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/write'

class WavefrontCliBaseTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Write.new({})
  end

  def test_dist_values
    assert_equal([[5, 12], [7, 1.1]], wf.dist_values(%w[5x12 7x1.1]))
  end
end
