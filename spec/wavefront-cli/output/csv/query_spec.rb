#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../helpers'
require_relative '../../../../lib/wavefront-cli/output/csv/query'

# Test CSV output
#
class WavefrontOutputCsvTest < MiniTest::Test
  attr_reader :wfq, :wfr, :wfqq, :wfh, :wft, :wftl

  def setup
    @wfq = WavefrontCsvOutput::Query.new(load_query_response, {})
    @wfr = WavefrontCsvOutput::Query.new(
      load_raw_query_response,
      raw: true,
      host: 'www-blue',
      '<metric>': 'solaris.network.obytes64'
    )
    @wfqq = WavefrontCsvOutput::Query.new(load_query_response,
                                          formatopts: 'quote')
    @wfh = WavefrontCsvOutput::Query.new(load_query_response,
                                         formatopts: 'headers')
    @wft = WavefrontCsvOutput::Query.new(load_query_response,
                                         formatopts: 'tagkeys')
    @wftl = WavefrontCsvOutput::Query.new(response_without_tags,
                                          formatopts: 'tagkeys')
  end

  def response_without_tags
    load_query_response.tap do |q|
      q[:timeseries].map do |r|
        r[:tags] = nil
        r
      end
    end
  end

  def test_all_keys
    assert_equal(%i[a b c d e],
                 wfq.all_keys([{ a: 1, b: 2 }, { a: 3, c: 3 },
                               { d: 4, e: 5 }, { a: 1 }]))
  end

  def test_csv_value
    assert_equal('word', wfq.csv_value('word'))
    assert_equal('"word"', wfqq.csv_value('word'))
    assert_equal('"7\" single"', wfq.quote_value('7" single'))
    assert_equal('"7\" single"', wfqq.quote_value('7" single'))
    assert_equal('"two words"', wfq.quote_value('two words'))
    assert_equal('"two words"', wfqq.quote_value('two words'))
    assert_equal('"a, b"', wfq.quote_value('a, b'))
    assert_equal('"a, b"', wfqq.quote_value('a, b'))
  end

  def test_quote_value
    assert_equal('"word"', wfq.quote_value('word'))
    assert_equal('"1"', wfr.quote_value(1))
    assert_equal('"two words"', wft.quote_value('two words'))
    assert_equal('"7\" single"', wfh.quote_value('7" single'))
  end

  def test_csv_headers
    assert_empty(wfq.csv_headers)
    wfh = WavefrontCsvOutput::Query.new(load_query_response,
                                        formatopts: 'headers')
    assert_equal(['path,value,timestamp,source,colour,environment,' \
                  'product,role,nic,platform,dc'], wfh.csv_headers)
  end

  def test_map_row_to_csv
    assert_equal(',,,,,,,,,,', wfq.map_row_to_csv(merp: 1))
    assert_equal('test.path,1,1544529523,testsource,,"unit test",,,,,',
                 wfq.map_row_to_csv(path: 'test.path',
                                    value: 1,
                                    timestamp: 1_544_529_523,
                                    source: 'testsource',
                                    environment: 'unit test'))
    assert_equal('"test.path","1","1544529523","testsource",,"unit test",,,,,',
                 wfqq.map_row_to_csv(path: 'test.path',
                                     value: 1,
                                     timestamp: 1_544_529_523,
                                     source: 'testsource',
                                     environment: 'unit test'))
  end

  def test_map_row_to_csv_without_tags
    assert_equal('test.path,1,1544529523,testsource',
                 wftl.map_row_to_csv(path: 'test.path',
                                     value: 1,
                                     timestamp: 1_544_529_523,
                                     source: 'testsource'))
  end

  def test_csv_format
    assert_equal({ path: 'test.path',
                   value: 1,
                   timestamp: 1_544_529_523,
                   source: 'testsource',
                   environment: 'test',
                   dc: 'travis' },
                 wfq.csv_format('test.path', 1, 1_544_529_523, 'testsource',
                                environment: 'test', dc: 'travis'))

    assert_equal({ path: 'test.path',
                   value: 1,
                   timestamp: 1_544_529_523,
                   source: 'testsource',
                   environment: 'environment=test',
                   dc: 'dc=travis' },
                 wft.csv_format('test.path', 1, 1_544_529_523, 'testsource',
                                environment: 'test', dc: 'travis'))
  end

  def test_tag_val
    assert_equal('value', wfq.tag_val('key', 'value'))
    assert_equal('value', wfr.tag_val('key', 'value'))
    assert_equal('key=value', wft.tag_val('key', 'value'))
    assert_equal('key=value', wft.tag_val(:key, :value))
  end

  def test__run_query
    out_q = wfq._run
    assert_equal(
      'solaris.network.obytes64,20910.38968253968,1533679200,' \
      'wavefront-blue,blue,production,websites,wavefront-proxy,net0,' \
      'JPC-triton,eu-ams-1', out_q.first
    )
    assert_equal(24, out_q.size)
    check_csv_output(out_q)

    out_h = wfh._run
    assert_equal(
      'path,value,timestamp,source,colour,environment,product,role,' \
      'nic,platform,dc', out_h.first
    )
    assert_equal(
      'solaris.network.obytes64,20910.38968253968,1533679200,' \
      'wavefront-blue,blue,production,websites,wavefront-proxy,net0,' \
      'JPC-triton,eu-ams-1', out_h[1]
    )
    assert_equal(25, out_h.size)

    out_t = wft._run
    assert_equal(
      'solaris.network.obytes64,20910.38968253968,1533679200,' \
      'wavefront-blue,colour=blue,environment=production,product=websites,' \
      'role=wavefront-proxy,nic=net0,' \
      'platform=JPC-triton,dc=eu-ams-1', out_t.first
    )
    assert_equal(24, out_t.size)
    check_csv_output(out_q)
  end

  def test__run_raw
    check_csv_output(wfq._run)
  end

  def check_csv_output(out)
    out.each do |l|
      c = l.split(',', 5)
      assert_equal(c[0], 'solaris.network.obytes64')
      assert_match(/^[\d\.]+$/, c[1])
      # query returns epoch s timestamp, raw returns epoch ms
      assert_match(/^\d+$/, c[2])
      assert(c[2].size == 10 || c[2].size == 13)
      assert(c[3] =~ /.*blue$/)
    end
  end
end
