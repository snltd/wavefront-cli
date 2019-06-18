#!/usr/bin/env ruby

id = 'test_dashboard'
bad_id = '>_<'
word = 'dashboard'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

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

  cmd_to_call(word,
              'favs',
              method: :post,
              path:   "/api/v2/search/#{word}",
              body:   { limit:  999,
                        offset: 0,
                        query:  [{ key:             'favorite',
                                   value:           'true',
                                   matchingMethod: 'EXACT',
                                   negated:         false }],
                        sort:   { field:     'id',
                                  ascending: true } }.to_json)

  spies = [{ class:  'WavefrontCli::Dashboard',
             method: :do_favs,
             return: nil }]

  cmd_to_call(word,
              "fav #{id}",
              { method: :post,
                path:   "/api/v2/#{word}/#{id}/favorite" },
              nil,
              spies)

  cmd_to_call(word,
              "unfav #{id}",
              { method: :post,
                path:   "/api/v2/#{word}/#{id}/unfavorite" },
              nil,
              spies)

  cmd_to_call(word, "undelete #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/undelete")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}"])
  tag_tests(word, id, bad_id)
  search_tests(word, id)
  test_list_output(word)
  acl_tests(word, id, bad_id)
end

class TestAlertMethods < CliMethodTest
  def cliclass
    WavefrontCli::Dashboard
  end

  def test_import_method
    import_tester(:dashboard,
                  %i[description name parameters tags url creatorId
                     sections parameterDetails displayDescription
                     acl numCharts],
                  %i[id])
  end
end
