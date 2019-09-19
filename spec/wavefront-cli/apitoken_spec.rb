#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/apitoken'

# Ensure 'apitoken' commands produce the correct API calls.
#
class ApiTokenEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete

  def test_list
    quietly { assert_cmd_gets('list', '/api/v2/apitoken') }
    assert_usage('list --offset 4')
    assert_abort_on_missing_creds('list')

    assert_noop('list',
                'uri: GET https://default.wavefront.com/api/v2/apitoken')
  end

  def test_create
    quietly { assert_cmd_posts('create', '/api/v2/apitoken') }
    assert_abort_on_missing_creds('create')
    assert_noop('create',
                'uri: POST https://default.wavefront.com/api/v2/apitoken',
                'body: null')
  end

  def _test_rename
    assert_cmd_puts("rename #{id} newname", "/api/v2/apitoken/#{id}",
                    tokenID: id, tokenName: 'newname')
    assert_invalid_id("rename #{invalid_id} newname")
    assert_abort_on_missing_creds("rename #{id} newname")

    assert_noop(
      "rename #{id} newname",
      "uri: PUT https://default.wavefront.com/api/v2/apitoken/#{id}",
      'body: {"tokenID":"17db4cc1-65f6-40a8-a1fa-6fcae460c4bd",' \
      '"tokenName":"newname"}'
    )
  end

  private

  def id
    '17db4cc1-65f6-40a8-a1fa-6fcae460c4bd'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'apitoken'
  end

  def sdk_class_name
    'ApiToken'
  end

  def friendly_name
    'api token'
  end
end
