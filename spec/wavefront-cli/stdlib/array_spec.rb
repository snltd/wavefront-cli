#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/wavefront-cli/stdlib/array'

# Test extensions to stlib Array
#
class TestArray < Minitest::Test
  def test_max_length
    assert_equal(7, %w[short longer longest].max_length)
    assert_equal(7, %i[short longer longest].max_length)
    assert_equal(0, [].max_length)
  end

  def test_longest_value_of
    input = [{ a: 'abc', b: 'def' }, { a: 'g', b: 'hjkl' }]
    assert_equal(3, input.longest_value_of(:a))
    assert_equal(4, input.longest_value_of(:b))
    assert_equal(0, input.longest_value_of(:c))
  end
end
