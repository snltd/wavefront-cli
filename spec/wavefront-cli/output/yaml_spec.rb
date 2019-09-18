#!/usr/bin/env ruby

require 'yaml'
require_relative 'helpers'
require 'minitest/autorun'
require_relative '../../../lib/wavefront-cli/output/yaml'

# Test YAML output
#
class WavefrontOutputYamlTest < MiniTest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Yaml.new(load_query_response)
  end

  def test__run
    out = wfo._run
    assert out.start_with?("---\n")
    po = YAML.safe_load(out)
    assert_equal(
      'rate(ts("solaris.network.obytes64", environment=production))',
      po['query']
    )
    assert_equal(4, po['timeseries'].size)
    assert_equal(6, po['timeseries'][0]['data'].size)
  end
end
