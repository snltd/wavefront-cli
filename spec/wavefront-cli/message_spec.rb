#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/message'

# Ensure 'message' commands produce the correct API calls.
#
class MessageEndToEndTest < EndToEndTest
  def test_list
    quietly do
      assert_cmd_gets('list',
                      '/api/v2/message?limit=100&offset=0&unreadOnly=true')
      assert_cmd_gets('list -l',
                      '/api/v2/message?limit=100&offset=0&unreadOnly=true')
    end

    assert_noop('list',
                'uri: GET https://default.wavefront.com/api/v2/message',
                'params: ' + {
                  offset: 0, limit: 100, unreadOnly: true
                }.to_s)

    assert_abort_on_missing_creds('list')
  end

  def test_list_offsets
    quietly do
      assert_cmd_gets('list --offset 2 --limit 3',
                      '/api/v2/message?limit=3&offset=2&unreadOnly=true')
    end
  end

  def test_list_all
    quietly do
      assert_cmd_gets('list -a',
                      '/api/v2/message?limit=100&offset=0&unreadOnly=false')
    end
  end

  def test_read
    # TODO: add a proper chained test like we have for
    # MaintenanceWindow#close, when there's some sample data to work
    # with. i.e. next time Wavefront send me a message
    assert_cannot_noop("read #{id}")
    assert_abort_on_missing_creds("read #{id}")
    assert_usage('read')
  end

  def test_mark
    quietly do
      assert_cmd_posts("mark #{id}", "/api/v2/message/#{id}/read")
    end

    assert_noop("mark #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "message/#{id}/read",
                'body: null')
    assert_abort_on_missing_creds("mark #{id}")
    assert_usage('mark')
  end

  private

  def id
    'CLUSTER::IHjNaHM9'
  end

  def invalid_id
    '(>_<)'
  end

  def cmd_word
    'message'
  end
end
