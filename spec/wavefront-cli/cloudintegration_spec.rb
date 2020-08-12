#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/cloudintegration'

# Ensure 'cloudintegration' commands produce the correct API calls.
#
class CloudIntegrationEndToEndTest < EndToEndTest
  # include WavefrontCliTest::DeleteUndelete
  # include WavefrontCliTest::Describe
  # include WavefrontCliTest::Dump
  # include WavefrontCliTest::List
  # include WavefrontCliTest::Search

  def test_enable
    assert_repeated_output("Enabled '#{id}'.") do
      assert_cmd_posts("enable #{id}",
                       "/api/v2/cloudintegration/#{id}/enable")
    end

    assert_invalid_id("enable #{invalid_id}")
    assert_usage('enable')
    assert_abort_on_missing_creds("enable #{id}")

    assert_noop("enable #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "cloudintegration/#{id}/enable",
                'body: null')
  end

  def test_disable
    assert_repeated_output("Disabled '#{id}'.") do
      assert_cmd_posts("disable #{id}",
                       "/api/v2/cloudintegration/#{id}/disable")
    end

    assert_invalid_id("disable #{invalid_id}")
    assert_usage('disable')
    assert_abort_on_missing_creds("disable #{id}")

    assert_noop("disable #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "cloudintegration/#{id}/disable",
                'body: null')
  end

  def test_aws_id_generate
    # assert_repeated_output("Disabled '#{id}'.") do
    # assert_cmd_posts("disable #{id}",
    # "/api/v2/cloudintegration/#{id}/disable")
    # end

    assert_abort_on_missing_creds('awsid generate')

    assert_noop('awsid generate',
                'uri: POST https://default.wavefront.com/api/v2/' \
                'cloudintegration/awsExternalId',
                'body: null')
  end

  private

  def id
    '3b56f61d-1a79-46f6-905c-d75a0f613d10'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'cloudintegration'
  end

  def sdk_class_name
    'CloudIntegration'
  end

  def friendly_name
    'cloud integration'
  end
end
