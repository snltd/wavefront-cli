#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../test_mixins/tag'
require_relative '../test_mixins/history'
require_relative '../../lib/wavefront-cli/derivedmetric'

# Ensure derivedmetric commands produce the correct API calls.
#
class DerivedMetricEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::DeleteUndelete
  include WavefrontCliTest::Search
  include WavefrontCliTest::Tag
  include WavefrontCliTest::History

  def test_create
    quietly do
      assert_cmd_posts('create mymetric ts(series)',
                       '/api/v2/derivedmetric',
                       minutes:                5,
                       name:                   'mymetric',
                       includeObsoleteMetrics: false,
                       processRateMinutes:     1,
                       query:                  'ts(series)')
    end

    assert_noop('create mymetric ts(series)',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'derivedmetric',
                'body: ' + {
                  query:                  'ts(series)',
                  name:                   'mymetric',
                  minutes:                5,
                  includeObsoleteMetrics: false,
                  processRateMinutes:     1
                }.to_json)

    quietly do
      assert_cmd_posts('create -i 3 -r 7 -b mymetric ts(series)',
                       '/api/v2/derivedmetric',
                       minutes:                7,
                       name:                   'mymetric',
                       includeObsoleteMetrics: true,
                       processRateMinutes:     3,
                       query:                  'ts(series)')
    end

    quietly do
      assert_cmd_posts('create -i 3 -T tag1 -T tag2 mymetric ts(series)',
                       '/api/v2/derivedmetric',
                       minutes:                5,
                       name:                   'mymetric',
                       includeObsoleteMetrics: false,
                       processRateMinutes:     3,
                       tags:                   %w[tag1 tag2],
                       query:                  'ts(series)')
    end

    assert_usage('create')
    assert_abort_on_missing_creds("create #{id} ts(series)")
  end

  private

  def id
    '1529926075038'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'derivedmetric'
  end

  def sdk_class_name
    'DerivedMetric'
  end

  def import_fields
    %i[tags minutes name query metricsUsed hostsUsed]
  end

  def friendly_name
    'derived metric'
  end
end
