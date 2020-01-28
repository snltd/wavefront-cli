#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/usage'

# Ensure 'usage' commands produce the correct API calls.
#
class UsageEndToEndTest < EndToEndTest
  def test_export_csv_start_time
    quietly do
      assert_cmd_gets(
        "export csv -s #{start_time}",
        "/api/v2/usage/exportcsv?startTime=#{start_time}",
        response
      )
    end

    assert_abort_on_missing_creds('export csv')
    assert_usage('export')
  end

  def test_export_csv_with_range
    quietly do
      assert_cmd_gets(
        "export csv -s #{start_time} -e #{end_time}",
        "/api/v2/usage/exportcsv?endTime=#{end_time}&startTime=#{start_time}",
        response
      )
    end
  end

  private

  def cmd_word
    'usage'
  end

  def api_path
    'usage'
  end

  def start_time
    1_579_500_000
  end

  def end_time
    1_579_533_333
  end

  def response
    IO.read(RES_DIR + 'responses' + 'usage-export-csv.json')
  end
end

# test class methods
#
class UsageTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Usage.new({})
  end

  def test_default_start
    calculated = Time.at(wf.default_start).to_date
    expected = Date.today - 1
    assert expected - calculated < 5
  end
end
