#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/query'
require 'wavefront-sdk/support/mixins'

# Ensure 'query' commands produce the correct API calls.
#
class QueryEndToEndTest < EndToEndTest
  include Wavefront::Mixins

  def test_query_specifying_start_of_window_no_sparkline
    out, err = capture_io do
      assert_cmd_gets_with_params("-s #{epoch_time[0]} -k #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'm',
                                    s: epoch_time[0].to_s }, canned_response)
    end

    assert_empty(err)
    assert_match(/name\s+ts\("cpu.0.pc.user"\)/, out)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
    refute_match(/sparkline/, out)

    assert_noop(
      "-s #{epoch_time[0]} -k #{query}",
      'uri: GET https://default.wavefront.com/api/v2/chart/api',
      'params: {:autoEvents=>false, :i=>false, :summarization=>"mean", ' \
      ':listMode=>true, :strict=>true, :includeObsoleteMetrics=>false, ' \
      ':sorted=>true, :q=>"ts(\"dev.cli.test\")", :g=>:m, ' \
      ":s=>#{epoch_time[0]}}"
    )
  end

  def test_query_with_start_and_end
    out, err = capture_io do
      assert_cmd_gets_with_params("#{start_and_end_opts} #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'm',
                                    s: epoch_time[0].to_s,
                                    e: epoch_time[1].to_s }, canned_response)
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_query_with_start_and_end_and_max_summary
    out, err = capture_io do
      assert_cmd_gets_with_params("#{start_and_end_opts} -S max #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'm',
                                    summarization: 'max',
                                    s: epoch_time[0].to_s,
                                    e: epoch_time[1].to_s }, canned_response)
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_query_with_start_and_end_and_max_number_of_points
    out, err = capture_io do
      assert_cmd_gets_with_params("#{start_and_end_opts} -p 100 #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'm',
                                    p: '100',
                                    s: epoch_time[0].to_s,
                                    e: epoch_time[1].to_s }, canned_response)
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_query_with_start_and_end_and_granularity_and_obsolete
    out, err = capture_io do
      assert_cmd_gets_with_params("#{start_and_end_opts} -g h -O #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'h',
                                    includeObsoleteMetrics: 'true',
                                    s: epoch_time[0].to_s,
                                    e: epoch_time[1].to_s }, canned_response)
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_query_with_start_and_end_and_nostrict_and_nocache
    out, err = capture_io do
      assert_cmd_gets_with_params("-s #{epoch_time[0]} -CK #{query}",
                                  '/api/v2/chart/api',
                                  { q: query,
                                    g: 'm',
                                    i: 'false',
                                    strict: 'false',
                                    s: epoch_time[0].to_s,
                                    cached: 'false' }, canned_response)
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_query_with_start_and_end_and_name
    out, err = capture_io do
      assert_cmd_gets_with_params(
        "#{start_and_end_opts} -g s -N query #{query}",
        '/api/v2/chart/api',
        { q: query,
          g: 's',
          n: 'query',
          s: epoch_time[0].to_s,
          e: epoch_time[1].to_s }, canned_response
      )
    end

    assert_empty(err)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
  end

  def test_raw
    assert_cmd_gets('raw dev.cli.test',
                    '/api/v2/chart/raw?metric=dev.cli.test')

    assert_noop('raw dev.cli.test',
                'uri: GET https://default.wavefront.com/api/v2/chart/raw',
                'params: {:metric=>"dev.cli.test"}')
    assert_abort_on_missing_creds('raw dev.cli.test')
  end

  def test_error_if_the_query_is_a_literal_raw
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets_with_params('raw',
                                    '/api/v2/chart/api',
                                    { g: 'm', q: 'raw' },
                                    { errorMessage: 'mock error' }.to_json)
      end
    end

    assert_empty(out)
    assert_equal("Invalid query. API message: 'mock error'.", err.strip)
  end

  def test_raw_with_host
    assert_cmd_gets('raw -H h1 dev.cli.test',
                    '/api/v2/chart/raw?metric=dev.cli.test&source=h1')
  end

  def test_raw_with_start_and_host
    assert_cmd_gets("raw -s #{wall_time[0].strftime('%H:%M')} " \
                    '-H h1 dev.cli.test',
                    '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{epoch_time[0]}")
  end

  def test_raw_with_start_and_end_and_host
    assert_cmd_gets("raw #{start_and_end_opts} -H h1 dev.cli.test",
                    '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{epoch_time[0]}&endTime=#{epoch_time[1]}")
  end

  private

  def query
    'ts("dev.cli.test")'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'query'
  end

  def canned_response
    IO.read(RES_DIR + 'responses' + 'query.json')
  end
end

#
# describe 'output formatting' do
#   it 'tests query output' do
#     out, err = command_output(word, :do_default, nil, 'query-cpu.json')
#     refute_empty(out)
#     assert_empty(err)
#     assert out.start_with?('name ')
#   end
# end

# Query tests
#
class QueryTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Query.new(endpoint: ENDPOINT)
  end

  def test_window_start
    assert_kind_of(Numeric, wf.window_start)
    assert_equal(13, wf.window_start.to_s.length)
  end

  def test_window_end
    assert_kind_of(Numeric, wf.window_start)
    assert_equal(13, wf.window_start.to_s.length)
  end

  def test_default_granularity
    minute = 60_000
    assert_equal(:s, wf.default_granularity(100))
    assert_equal(:s, wf.default_granularity(10_000))
    assert_equal(:m, wf.default_granularity(120 * minute))
    assert_equal(:h, wf.default_granularity(4 * 60 * minute))
    assert_equal(:d, wf.default_granularity(4 * 24 * 60 * minute))
    assert_equal(:s, wf.default_granularity(-100))
    assert_equal(:s, wf.default_granularity(-10_000))
    assert_equal(:m, wf.default_granularity(-120 * minute))
    assert_equal(:h, wf.default_granularity(-4 * 60 * minute))
    assert_equal(:d, wf.default_granularity(-4 * 24 * 60 * minute))
  end
end
