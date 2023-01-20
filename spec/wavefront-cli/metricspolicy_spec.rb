#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/metricspolicy'

# Ensure 'metricspolicy' commands produce the correct API calls.
#
class MetricsPolicyEndToEndTest < EndToEndTest
  def test_describe
    quietly do
      assert_cmd_gets('describe', '/api/v2/metricspolicy')
      assert_cmd_gets('describe -v4', '/api/v2/metricspolicy/history/4')
    end
  end

  def _test_revert
    quietly do
      assert_cmd_posts('revert 2', '/api/v2/metricspolicy/revert/2')
    end
  end

  def cmd_word
    'metricspolicy'
  end

  def sdk_class_name
    'MetricsPolicy'
  end
end
