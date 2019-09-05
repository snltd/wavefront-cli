#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../test_mixins/tag'
require_relative '../../lib/wavefront-cli/source'

class SourceEndToEndTest < EndToEndTest
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Search
  include WavefrontCliTest::Tag

  def test_list
    quietly { assert_cmd_gets('list', '/api/v2/source') }
    assert_noop('list',
                'uri: GET https://default.wavefront.com/api/v2/source')
    assert_abort_on_missing_creds('list')
  end

  def test_list_with_limit
    quietly { assert_cmd_gets('list -L 10', '/api/v2/source?limit=10') }

    assert_noop('list -L 10',
                'uri: GET https://default.wavefront.com/api/v2/source',
                'params: {:limit=>"10"}')
  end

  def test_list_with_cursor
    quietly do
      assert_cmd_gets('list --cursor box', '/api/v2/source?cursor=box')
    end

    assert_usage('list --offset 3')
  end

  def test_description_set
    quietly do
      assert_cmd_posts("description set #{id} tester",
                       "/api/v2/source/#{id}/description",
                       'tester')
    end

    assert_noop("description set #{id} tester",
                'uri: POST https://default.wavefront.com/api/v2/source' \
                "/#{id}/description",
                'body: tester')

    assert_invalid_id("description set #{invalid_id} tester")
    assert_usage('description')
    assert_usage('description set')
    assert_usage("description set #{id}")
    assert_abort_on_missing_creds("description set #{id} tester")
  end

  def test_description_clear
    quietly do
      assert_cmd_deletes("description clear #{id}",
                         "/api/v2/source/#{id}/description")
    end

    assert_noop("description clear #{id}",
                'uri: DELETE https://default.wavefront.com/api/v2/source' \
                "/#{id}/description")

    assert_invalid_id("description clear #{invalid_id}")
    assert_usage('description')
    assert_usage('description clear')
    assert_abort_on_missing_creds("description clear #{id}")
  end

  def test_clear
    quietly do
      assert_cmd_deletes("clear #{id}", "/api/v2/source/#{id}")
    end

    assert_noop("clear #{id}",
                'uri: DELETE https://default.wavefront.com/api/v2/source' \
                "/#{id}")

    assert_invalid_id("clear #{invalid_id}")
    assert_abort_on_missing_creds("clear #{id}")
    assert_usage('clear')
  end

  # We tell the search mixin not to test with limits, so we'll have
  # to test a cursor ourselves.
  #
  def test_search_equals_with_cursor
    assert_repeated_output('No matches.') do
      assert_cmd_posts("search id=#{id} -L 5 --cursor box",
                       "/api/v2/search/#{api_class}",
                       limit:  '5',
                       cursor: 'box',
                       query:  [{ key: 'id',
                                  value: id,
                                  matchingMethod: 'EXACT',
                                  negated: false }],
                       sort:   { field: 'id', ascending: true })
    end

    assert_abort_on_missing_creds("search id=#{id} -L 5 --cursor box")
  end

  private

  def id
    '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
  end

  def invalid_id
    '(>_<)'
  end

  def cmd_word
    'source'
  end

  def cannot_handle_offsets
    true
  end
end
