#!/usr/bin/env ruby

require_relative '../../lib/wavefront-cli/write'

# Test base writer
#
class WavefrontCliWriteTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Write.new({})
  end

  def test_expand_dist
    assert_equal(wf.expand_dist([1, 1, 1]), [1, 1, 1])
    assert_equal(wf.expand_dist(['3x1']), [1, 1, 1])
    assert_equal(wf.expand_dist(%w[3x1 1x4]), [1, 1, 1, 4])
    assert_equal(wf.expand_dist([1, 1, 1, '2x2']).sort, [2, 2, 1, 1, 1].sort)
  end
end
