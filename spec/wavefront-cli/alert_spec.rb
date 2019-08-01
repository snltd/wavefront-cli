#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../test_mixins/acl'
require_relative '../test_mixins/tag'
require_relative '../test_mixins/history'
require_relative '../../lib/wavefront-cli/alert'

# Ensure 'alert' commands produce the correct API calls.
#
class AlertEndToEndTest < EndToEndTest
  include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::DeleteUndelete
  include WavefrontCliTest::Dump
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Search
  include WavefrontCliTest::Tag
  include WavefrontCliTest::History
  include WavefrontCliTest::Acl

  def test_latest
    quietly do
      assert_cmd_gets("latest #{id}", "/api/v2/alert/#{id}/history")
    end

    assert_noop("latest #{id}",
                'uri: GET https://default.wavefront.com/api/v2/' \
                "alert/#{id}/history")

    assert_invalid_id("latest #{invalid_id}")
    assert_usage('latest')
    assert_abort_on_missing_creds("latest #{id}")
  end

  def test_queries
    quietly do
      assert_cmd_gets('queries', '/api/v2/alert?limit=999&offset=0')
    end
  end

  def test_clone
    quietly do
      assert_cmd_posts("clone #{id}",
                       "/api/v2/alert/#{id}/clone",
                       id: id, v: nil, name: nil)
    end

    assert_noop("clone #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/clone",
                'body: ' + { id: id, name: nil, v: nil }.to_json)

    assert_invalid_id("clone #{invalid_id}")
    assert_usage('clone')
    assert_abort_on_missing_creds("clone #{id}")
  end

  def test_clone_v
    quietly do
      assert_cmd_posts("clone #{id} -v5",
                       "/api/v2/alert/#{id}/clone",
                       id: id, v: 5, name: nil)
    end

    assert_noop("clone #{id} --version 5",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/clone",
                'body: ' + { id: id, name: nil, v: 5 }.to_json)

    assert_invalid_id("clone -v 10 #{invalid_id}")
    assert_usage('clone -v')
    assert_abort_on_missing_creds("clone -v5 #{id}")
  end

  def test_snooze
    assert_repeated_output("Snoozed alert '#{id}' indefinitely.") do
      assert_cmd_posts("snooze #{id}", "/api/v2/alert/#{id}/snooze")
    end

    assert_noop("snooze #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/snooze",
                'body: null')
    assert_usage('snooze')
    assert_abort_on_missing_creds("snooze #{id}")
  end

  def test_snooze_t
    assert_repeated_output("Snoozed alert '#{id}' for 800 seconds.") do
      assert_cmd_posts("snooze -T 800 #{id}",
                       "/api/v2/alert/#{id}/snooze?seconds=800")
    end

    assert_noop("snooze -T 800 #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/snooze",
                'body: null')
    assert_usage('snooze -T')
    assert_invalid_id("snooze -T 100 #{invalid_id}")
    assert_abort_on_missing_creds("snooze -T 800 #{id}")
  end

  def test_unsnooze
    assert_repeated_output("Unsnoozed alert '#{id}'.") do
      assert_cmd_posts("unsnooze #{id}",
                       "/api/v2/alert/#{id}/unsnooze")
    end

    assert_noop("unsnooze #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/unsnooze",
                'body: null')
    assert_invalid_id("unsnooze #{invalid_id}")
    assert_usage('unsnooze')
    assert_abort_on_missing_creds("unsnooze #{id}")
  end

  def test_install
    quietly do
      assert_cmd_posts("install #{id}",
                       "/api/v2/alert/#{id}/install")
    end

    assert_noop("install #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/install",
                'body: null')
    assert_invalid_id("install #{invalid_id}")
    assert_usage('install')
    assert_abort_on_missing_creds("install #{id}")
  end

  def test_uninstall
    quietly do
      assert_cmd_posts("uninstall #{id}",
                       "/api/v2/alert/#{id}/uninstall")
    end

    assert_noop("uninstall #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "alert/#{id}/uninstall",
                'body: null')
    assert_invalid_id("uninstall #{invalid_id}")
    assert_usage('uninstall')
    assert_abort_on_missing_creds("uninstall #{id}")
  end

  def test_summary
    quietly { assert_cmd_gets('summary', '/api/v2/alert/summary') }

    assert_noop(
      'summary',
      'uri: GET https://default.wavefront.com/api/v2/alert/summary'
    )
    assert_abort_on_missing_creds('summary')
  end

  def test_snoozed
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('snoozed',
                         '/api/v2/search/alert',
                         state_search('snoozed').to_json)
      end
    end

    assert_empty(err)
    assert_equal('No alerts are currently snoozed.', out.rstrip)

    assert_noop('snoozed',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'search/alert',
                'body: ' + state_search('snoozed').to_json)

    assert_abort_on_missing_creds('snoozed')
  end

  def test_firing
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('firing',
                         '/api/v2/search/alert',
                         state_search('firing').to_json)
      end
    end

    assert_empty(err)
    assert_equal('No alerts are currently firing.', out.rstrip)

    assert_noop('firing',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'search/alert',
                'body: ' + state_search('firing').to_json)

    assert_abort_on_missing_creds('firing')
  end

  def test_currently_firing
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('currently firing',
                         '/api/v2/search/alert',
                         state_search('firing').to_json)
      end
    end

    assert_empty(err)
    assert_equal('No alerts are currently firing.', out.rstrip)

    assert_noop('currently firing',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'search/alert',
                'body: ' + state_search('firing').to_json)

    assert_abort_on_missing_creds('currently firing')
  end

  def test_currently_in_maintenance
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('currently in_maintenance',
                         '/api/v2/search/alert',
                         state_search('in_maintenance').to_json)
      end
    end

    assert_empty(err)
    assert_equal('No alerts are currently in_maintenance.', out.rstrip)

    assert_noop('currently in_maintenance',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'search/alert',
                'body: ' + state_search('in_maintenance').to_json)

    assert_abort_on_missing_creds('currently in_maintenance')
  end

  private

  def id
    '1481553823153'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'alert'
  end

  def state_search(state)
    { limit: 999,
      offset: 0,
      query: [{ key:            'status',
                value:          state,
                matchingMethod: 'EXACT',
                negated:        false }],
      sort: { field: 'status', ascending: true } }
  end

  def import_fields
    %i[condition displayExpression resolveAfterMinutes minutes severity
       tags target name]
  end

  # rubocop:disable Metrics/LineLength
  def import_data
    { name: 'PKS - too many containers not running',
      condition:      'sum(ts(pks.kube.pod.container.status.running.gauge)) / (sum(ts(pks.kube.pod.container.status.running.gauge)) + sum(ts(pks.kube.pod.container.status.waiting.gauge)) + sum(ts(pks.kube.pod.container.status.terminated.gauge))) < 0.8',
      minutes: 5,
      target: 'target:9wltLtYXsP8Je2kI',
      severity: 'SEVERE',
      displayExpression:      'sum(ts(pks.kube.pod.container.status.running.gauge)) / (sum(ts(pks.kube.pod.container.status.running.gauge)) + sum(ts(pks.kube.pod.container.status.waiting.gauge)) + sum(ts(pks.kube.pod.container.status.terminated.gauge)))',
      tags: { customerTags: ['pks'] },
      additionalInformation: nil,
      resolveAfterMinutes: 5,
      resolveMinutes: 5 }
  end

  def update_data
    { name: 'PKS - too many containers not running',
      condition:    'sum(ts(pks.kube.pod.container.status.running.gauge)) / (sum(ts(pks.kube.pod.container.status.running.gauge)) + sum(ts(pks.kube.pod.container.status.waiting.gauge)) + sum(ts(pks.kube.pod.container.status.terminated.gauge))) < 0.8',
      minutes: 5,
      target: 'target:9wltLtYXsP8Je2kI',
      severity: 'SEVERE',
      displayExpression:    'sum(ts(pks.kube.pod.container.status.running.gauge)) / (sum(ts(pks.kube.pod.container.status.running.gauge)) + sum(ts(pks.kube.pod.container.status.waiting.gauge)) + sum(ts(pks.kube.pod.container.status.terminated.gauge)))',
      tags: { customerTags: ['pks'] },
      resolveAfterMinutes: 5,
      id: '1556812163465' }
  end
  # rubocop:enable Metrics/LineLength
end
