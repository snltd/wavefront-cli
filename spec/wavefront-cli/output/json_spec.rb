#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative 'helpers'
require_relative '../../../lib/wavefront-cli/output/json'

# Test JSON output
#
class WavefrontOutputJsonTest < MiniTest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Json.new(load_query_response)
  end

  def test_my_format
    assert('json', wfo.my_format)
  end

  def test__run
    out = wfo._run
    po = JSON.parse(out)
    assert JSON.parse(po.to_json)
    assert_equal(
      'rate(ts("solaris.network.obytes64", environment=production))',
      po['query']
    )
    assert_equal(4, po['timeseries'].size)
    assert_equal(6, po['timeseries'][0]['data'].size)
  end
end
