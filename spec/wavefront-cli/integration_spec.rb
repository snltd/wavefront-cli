#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/integration'

# Ensure 'integration' commands produce the correct API calls.
#
class IntegrationEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Search

  def test_install
    quietly do
      assert_cmd_posts("install #{id}",
                       "/api/v2/integration/#{id}/install",
                       'null')
    end

    assert_invalid_id("install #{invalid_id}")
    assert_usage('install')
    assert_abort_on_missing_creds("install #{id}")

    assert_noop("install #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "integration/#{id}/install",
                'body: null')
  end

  def test_uninstall
    quietly do
      assert_cmd_posts("uninstall #{id}",
                       "/api/v2/integration/#{id}/uninstall",
                       'null')
    end

    assert_invalid_id("uninstall #{invalid_id}")
    assert_usage('uninstall')
    assert_abort_on_missing_creds("uninstall #{id}")

    assert_noop("uninstall #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "integration/#{id}/uninstall",
                'body: null')
  end

  def test_manifests
    assert_exits_with('Human-readable manifest output is not supported.',
                      'manifests -f human')

    quietly do
      assert_cmd_gets('manifests -f json', '/api/v2/integration/manifests')
    end

    assert_noop('manifests --format yaml',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'integration/manifests')
    assert_abort_on_missing_creds('manifests')
  end

  def test_status
    quietly do
      assert_cmd_gets("status #{id}", "/api/v2/integration/#{id}/status")
    end

    assert_invalid_id("status #{invalid_id}")
    assert_noop("status #{id}",
                'uri: GET https://default.wavefront.com/api/v2/' \
                "integration/#{id}/status")
    assert_abort_on_missing_creds("status #{id}")
  end

  def test_statuses
    quietly do
      assert_cmd_gets('statuses', '/api/v2/integration/status')
    end

    assert_noop('statuses',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'integration/status')
    assert_abort_on_missing_creds('statuses')
  end

  def test_alert_install
    quietly do
      assert_cmd_posts("alert install #{id}",
                       "/api/v2/integration/#{id}/install-all-alerts",
                       'null')
    end

    assert_invalid_id("alert install #{invalid_id}")
    assert_usage('alert install')
    assert_abort_on_missing_creds("alert install #{id}")

    assert_noop("alert install #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "integration/#{id}/install-all-alerts",
                'body: null')
  end

  def test_alert_uninstall
    quietly do
      assert_cmd_posts("alert uninstall #{id}",
                       "/api/v2/integration/#{id}/uninstall-all-alerts",
                       'null')
    end

    assert_invalid_id("alert uninstall #{invalid_id}")
    assert_usage('alert uninstall')
    assert_abort_on_missing_creds("alert uninstall #{id}")

    assert_noop("alert uninstall #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "integration/#{id}/uninstall-all-alerts",
                'body: null')
  end

  def test_installed
    quietly do
      assert_cmd_gets('installed', '/api/v2/integration/installed')
    end

    assert_noop('installed',
                'uri: GET https://default.wavefront.com/api/v2/' \
                'integration/installed')
    assert_abort_on_missing_creds('installed')
  end

  private

  def id
    'tester'
  end

  def invalid_id
    '%%badid%%'
  end

  def cmd_word
    'integration'
  end
end
