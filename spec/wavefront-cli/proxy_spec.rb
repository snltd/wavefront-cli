#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/proxy'

class ProxyEndToEndTest < EndToEndTest
  include WavefrontCliTest::DeleteUndelete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::List
  include WavefrontCliTest::Search

  def test_versions
    quietly do
      assert_cmd_gets('versions', '/api/v2/proxy?limit=999&offset=0')
    end

    assert_abort_on_missing_creds('versions')
    assert_noop('versions',
                'uri: GET https://default.wavefront.com/api/v2/proxy',
                'params: {:offset=>0, :limit=>999}')
  end

  def test_rename
    quietly do
      assert_cmd_puts("rename #{id} newname", "/api/v2/proxy/#{id}",
                      tokenID: id, tokenName: 'newname')
    end

    assert_noop("rename #{id} newname",
                "uri: PUT https://default.wavefront.com/api/v2/proxy/#{id}",
                'body: {"name":"newname"}')
    assert_invalid_id("rename #{invalid_id} newname")
    assert_abort_on_missing_creds("rename #{id} newname")
  end

  private

  def id
    'fd248f53-378e-4fbe-bbd3-efabace8d724'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'proxy'
  end
end
