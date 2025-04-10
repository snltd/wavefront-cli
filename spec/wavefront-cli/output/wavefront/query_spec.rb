#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../helpers'
require_relative '../../../../lib/wavefront-cli/output/wavefront/query'

# Test Wavefront wire-format output
#
class WavefrontOutputWavefrontTest < Minitest::Test
  attr_reader :wfq, :wfr

  def setup
    @wfq = WavefrontWavefrontOutput::Query.new(load_query_response, {})
    @wfr = WavefrontWavefrontOutput::Query.new(
      load_raw_query_response,
      raw: true,
      host: 'www-blue',
      '<metric>': 'solaris.network.obytes64'
    )
  end

  def test_wavefront_format
    assert_equal(
      'metric.path 1.23 1533682320 source=testhost',
      wfq.wavefront_format('metric.path', 1.23, 1_533_682_320, 'testhost')
    )

    assert_equal(
      'metric.path 1.234567 1533682320 source=testhost tag="val"',
      wfq.wavefront_format('metric.path', 1.234567, 1_533_682_320,
                           'testhost', tag: 'val')
    )

    assert_equal(
      'metric.path 1 1533682320 source=testhost tag1="val1" tag2="val2"',
      wfq.wavefront_format('metric.path', 1, 1_533_682_320, 'testhost',
                           tag1: 'val1', tag2: 'val2')
    )
  end

  def test__run_query
    out = wfq._run.split("\n")

    assert_equal(
      'solaris.network.obytes64 20910.38968253968 1533679200 ' \
      'source=wavefront-blue colour="blue" environment="production" ' \
      'product="websites" role="wavefront-proxy" nic="net0" ' \
      'platform="JPC-triton" dc="eu-ams-1"', out[0]
    )

    assert_equal(24, out.size)
    check_wf_native_output(out)
  end

  def test__run_raw
    check_wf_native_output(wfq._run.split("\n"))
  end

  def check_wf_native_output(out)
    vals = [10, 13]
    out.each do |l|
      c = l.split(' ', 5)
      assert_equal(c[0], 'solaris.network.obytes64')
      assert_match(/^[\d.]+$/, c[1])
      # query returns epoch s timestamp, raw returns epoch ms
      assert_match(/^\d+$/, c[2])
      assert(vals.include?(c[2].size))
      assert_match(/^source=[-\w]+$/, c[3])
      assert_match(/^source=[-\w]+$/, c[3])
      c[4].split.each { |t| assert_match(/^\w+="[-\w]+"$/, t) }
    end
  end
end
