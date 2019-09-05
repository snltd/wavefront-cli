#!/usr/bin/env ruby

word = 'query'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"
require 'wavefront-sdk/support/mixins'
# rubocop:disable Style/MixinUsage
include Wavefront::Mixins
# rubocop:enable Style/MixinUsage

q = 'ts("dev.cli.test")'
#
# The SDK has got smarter about calculating granularity options, so
# we can't use any kind of absolute time any more. We round time
# down to the nearest minute, because that's how users will most
# likely specify it.
#
t1_t = Time.now - (30 * 60)
t1_t = Time.at(t1_t.to_i - t1_t.sec)
t2_t = Time.at(t1_t + (10 * 60))

t1 = parse_time(t1_t, true)
t2 = parse_time(t2_t, true)
o = "-g m -s #{t1_t.strftime('%H:%M')}"
s_and_e_opts = "-s #{t1_t.strftime('%H:%M')} -e #{t2_t.strftime('%H:%M')}"

describe "#{word} command" do
  cmd_to_call(word, "-s -2h #{q}",
              path: '/api/v2/chart/api\\?g=m&i=false' \
                    '&listMode=true&q=ts\(%22dev.cli.test%22\)' \
                    '&s=[0-9]{13}&sorted=true&strict=true&summarization=mean',
              regex: true)

  missing_creds(word, ["#{o} '#{q}'", "raw #{q}"])

  cmd_noop(word, "-s #{t1} #{q}",
           ['GET https://metrics.wavefront.com/api/v2/chart/api',
            i: false, summarization: 'mean', listMode: true, strict: true,
            sorted: true, q: q, g: :m, s: t1])

  cmd_noop(word, 'raw dev.cli.test',
           ['GET https://metrics.wavefront.com/api/v2/chart/raw',
            metric: 'dev.cli.test'])

  cmd_to_call(word, "#{o} #{q}",
              path: '/api/v2/chart/api?g=m&i=false&listMode=true' \
                    "&q=ts(%22dev.cli.test%22)&s=#{t1}&sorted=true" \
                    '&strict=true&summarization=mean')

  cmd_to_call(word, "#{s_and_e_opts} #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=m&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&strict=true&summarization=mean")

  cmd_to_call(word, "-g s #{s_and_e_opts} -S max #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=s&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&strict=true&summarization=max")

  cmd_to_call(word, "-g s #{s_and_e_opts} -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=s&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean&strict=true" \
                    '&p=100')

  cmd_to_call(word, "-iO -g h #{s_and_e_opts} -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=h&i=true" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean" \
                    '&strict=true&p=100&includeObsoleteMetrics=true')

  cmd_to_call(word, "-N query -g h #{s_and_e_opts} -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=h&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean" \
                    '&strict=true&p=100&n=query')

  cmd_to_call(word, 'raw dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test')

  cmd_to_call(word, 'raw -H h1 dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1')

  cmd_to_call(word, "raw -s #{t1_t.strftime('%H:%M')} -H h1 dev.cli.test",
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{t1}")

  cmd_to_call(word, "raw #{s_and_e_opts} -H h1 dev.cli.test",
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{t1}&endTime=#{t2}")
end

describe 'output formatting' do
  it 'tests query output' do
    out, err = command_output(word, :do_default, nil, 'query-cpu.json')
    refute_empty(out)
    assert_empty(err)
    assert out.start_with?('name ')
  end
end

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
