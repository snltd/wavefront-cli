#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/apitoken'

class ApiTokenEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete

  def test_list
    assert_cmd_gets('list', '/api/v2/apitoken')
    assert_usage('list --offset 4')
    assert_abort_on_missing_creds('list')

    assert_noop('list',
                'uri: GET https://default.wavefront.com/api/v2/apitoken')
  end

  def test_create
    assert_cmd_posts('create', '/api/v2/apitoken', nil)
    assert_abort_on_missing_creds('create')
    assert_noop('create',
                'uri: POST https://default.wavefront.com/api/v2/apitoken',
                'body: null')
  end

  def test_rename
    assert_cmd_puts("rename #{id} newname", "/api/v2/apitoken/#{id}",
                    tokenID: id, tokenName: 'newname')
    assert_invalid_id("rename #{invalid_id} newname")
    assert_abort_on_missing_creds("rename #{id} newname")

    assert_noop(
        "rename #{id} newname",
        "uri: PUT https://default.wavefront.com/api/v2/apitoken/#{id}",
        'body: {"tokenID":"17db4cc1-65f6-40a8-a1fa-6fcae460c4bd",' \
        '"tokenName":"newname"}')
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
end
