#!/usr/bin/env ruby

id = 'test_dashboard'
bad_id = '>_<'
word = 'dashboard'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

# Method tests. CLI tests follow
#
class WavefrontCliDashboardTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Dashboard.new({})
  end

  def test_user_lists
    assert_equal({ modify: [],
                   view: [{ name: 'a@bc.com', id: 'a@bc.com' },
                          { name: 'x@yz.com', id: 'x@yz.com' }] },
                 wf.user_lists(:view, %w[a@bc.com x@yz.com]))

    assert_equal({ view: [],
                   modify: [{ name: 'a@bc.com', id: 'a@bc.com' },
                            { name: 'x@yz.com', id: 'x@yz.com' }] },
                 wf.user_lists(:modify, %w[a@bc.com x@yz.com]))
  end
end

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}",
                       "undelete #{id}", "history #{id}"])
  list_tests(word)
  noop_tests(word, id, true)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "describe -v 7 #{id}",
              path: "/api/v2/#{word}/#{id}/history/7")
  cmd_to_call(word, "history #{id}", path: "/api/v2/#{word}/#{id}/history")

  it 'deletes with a check on inTrash' do
    stub_request(:get,
                 "https://other.wavefront.com/api/v2/#{word}/#{id}")
      .with(headers: { 'Accept': '*/*',
                       'Accept-Encoding':
                          'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization': 'Bearer 0123456789-ABCDEF',
                       'User-Agent': /wavefront.*/ })
      .to_return(status: 200, body: '', headers: {})
    cmd_to_call(word, "delete #{id}",
                method: :delete, path: "/api/v2/#{word}/#{id}")
  end

  cmd_to_call(word, "search id=#{id}",
              method: :post, path: "/api/v2/search/#{word}",
              body:   { limit: 10,
                        offset: 0,
                        query: [{ key: 'id',
                                  value: id,
                                  matchingMethod: 'EXACT' }],
                        sort: { field: 'id', ascending: true } },
              headers: JSON_POST_HEADERS)
  cmd_to_call(word,
              'favs',
              method: :post,
              path:   "/api/v2/search/#{word}",
              body:   { limit:  999,
                        offset: 0,
                        query:  [{ key:             'favorite',
                                   value:           'true',
                                   matchingMethod: 'EXACT' }],
                        sort:   { field:     'id',
                                  ascending: true } }.to_json)

  cmd_to_call(word,
              "fav #{id}",
              { method: :post,
                path:   "/api/v2/#{word}/#{id}/favorite" },
              nil,
              ['WavefrontCli::Dashboard', :do_favs])

  cmd_to_call(word,
              "unfav #{id}",
              { method: :post,
                path:   "/api/v2/#{word}/#{id}/unfavorite" },
              nil,
              ['WavefrontCli::Dashboard', :do_favs])
  cmd_to_call(word, "undelete #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/undelete")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}"])
  tag_tests(word, id, bad_id)
  test_list_output(word)
end
