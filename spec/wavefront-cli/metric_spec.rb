#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/metric'

# Ensure 'metric' commands produce the correct API calls.
#
class MetricEndToEndTest < EndToEndTest
  def test_describe
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets("describe #{id}",
                        "/api/v2/chart/metric/detail?m=#{id}")
      end
    end

    assert_equal("Did not find metric 'dev.cli.test'.", out.strip)
    assert_empty(err)

    assert_invalid_id("describe #{invalid_id}")
    assert_usage('describe')
    assert_abort_on_missing_creds("describe #{id}")
  end

  def test_describe_with_globs
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets("describe -g ptn1 -g ptn2 #{id}",
                        "/api/v2/chart/metric/detail?m=#{id}&h=ptn1&h=ptn2")
      end
    end

    assert_equal("Did not find metric 'dev.cli.test'.", out.strip)
    assert_empty(err)
  end

  def test_describe_with_glob_and_offset
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets("describe -g ptn1 -o 5 #{id}",
                        "/api/v2/chart/metric/detail?m=#{id}&h=ptn1&c=5")
      end
    end

    assert_equal("Did not find metric 'dev.cli.test'.", out.strip)
    assert_empty(err)
  end

  private

  def id
    'dev.cli.test'
  end

  def invalid_id
    '(>_<)'
  end

  def cmd_word
    'metric'
  end
end
