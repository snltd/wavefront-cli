#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../test_mixins/tag'
require_relative '../../lib/wavefront-cli/monitoredcluster'

# Ensure 'cluster' commands produce the correct API calls.
#
class MonitoredClusterEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::List
  include WavefrontCliTest::Search
  include WavefrontCliTest::Tag

  def test_create
    quietly do
      assert_cmd_posts("create EKS cluster #{id}",
                       '/api/v2/monitoredcluster',
                       version: nil,
                       name: 'cluster',
                       platform: 'EKS',
                       id: 'test-cluster',
                       additionalTags: {},
                       tags: [])
    end

    assert_abort_on_missing_creds("create EKS cluster #{id}")
    assert_noop("create EKS -v 1.2 cluster #{id}",
                'uri: POST https://default.wavefront.com/api/v2/monitoredcluster',
                "body: #{ { version: '1.2',
                            name: 'cluster',
                            platform: 'EKS',
                            id: 'test-cluster',
                            additionalTags: {},
                            tags: [] }.to_json}")
  end

  def test_merge
    quietly do
      assert_cmd_puts(
        "merge #{id} #{id2}", "/api/v2/monitoredcluster/merge/#{id}/#{id2}",
        {}
      )
    end

    assert_noop("merge #{id} #{id2}",
                'uri: PUT https://default.wavefront.com/api/v2/' \
                "monitoredcluster/merge/#{id}/#{id2}",
                'body: null')
    assert_invalid_id("merge #{invalid_id} #{id2} -D")
    assert_abort_on_missing_creds("merge #{id} #{id2}")
  end

  private

  def id
    'test-cluster'
  end

  def id2
    'other-cluster'
  end

  def invalid_id
    '!__BAD__!'
  end

  def cmd_word
    'cluster'
  end

  def api_path
    'monitoredcluster'
  end

  def sdk_class_name
    'MonitoredCluster'
  end

  def friendly_name
    'monitored cluster'
  end
end
