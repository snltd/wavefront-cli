#!/usr/bin/env ruby

require 'wavefront-sdk/support/mixins'
require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/query'

TEE_ZERO = Time.now.freeze

# Ensure 'query' commands produce the correct API calls.
#
class QueryEndToEndTest < EndToEndTest
  include Wavefront::Mixins

  def _test_query_last_two_hours
    out, err = capture_io do
      assert_cmd_gets_with_params("--start='-2h' #{query}",
                                  '/api/v2/chart/api',
                                  { g: 'h',
                                    sorted: 'true',
                                    strict: 'true',
                                    summarization: 'mean',
                                    q: query }, canned_response)
    end

    assert_empty(err)
    assert_match(/name\s+ts\("cpu.0.pc.user"\)/, out)
    assert_match(/query\s+ts\("cpu.0.pc.user"\)/, out)
    assert_match(/sparkline/, out)
  end

  def _test_query_specifying_start_of_window_no_sparkline
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
      'params: {:i=>false, :summarization=>"mean", :listMode=>true, ' \
      ':strict=>true, :sorted=>true, :q=>"ts(\"dev.cli.test\")", ' \
      ":g=>:m, :s=>#{epoch_time[0]}}"
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

  def _test_raw
    assert_cmd_gets('raw dev.cli.test',
                    '/api/v2/chart/raw?metric=dev.cli.test')

    assert_noop('raw dev.cli.test',
                'uri: GET https://default.wavefront.com/api/v2/chart/raw',
                'params: {:metric=>"dev.cli.test"}')
    assert_abort_on_missing_creds('raw dev.cli.test')
  end

  def _test_error_if_the_query_is_a_literal_raw
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

  def _test_raw_with_host
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

  def wall_time
    half_an_hour_ago = TEE_ZERO - (30 * 60)
    start_time = Time.at(half_an_hour_ago.to_i - half_an_hour_ago.sec)
    [start_time, Time.at(start_time + (10 * 60))]
  end

  def epoch_time
    wall_time.map { |t| parse_time(t, true) }
  end

  def start_and_end_opts
    format('-s %s -e %s',
           wall_time[0].strftime('%H:%M'),
           wall_time[1].strftime('%H:%M'))
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
