#!/usr/bin/env ruby

id = '1481553823153'
bad_id = '__bad_id__'
word = 'alert'

def search_body(val)
  { limit: 999,
    offset: 0,
    query: [
      { key: 'status',
        value: val,
        matchingMethod: 'EXACT' }
    ],
    sort: { field: 'status', ascending: true } }
end

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "snooze #{id}",
                       'queries', 'snoozed', "install #{id}",
                       "uninstall #{id}", 'firing',
                       'currently firing', 'summary',
                       "delete #{id}", "undelete #{id}", "history #{id}"])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "describe -v 7 #{id}",
              path: "/api/v2/#{word}/#{id}/history/7")
  cmd_to_call(word, "history #{id}", path: "/api/v2/#{word}/#{id}/history")

  it 'deletes with a check on inTrash' do
    stub_request(:get,
                 'https://other.wavefront.com/api/v2/alert/1481553823153')
      .with(headers: { 'Accept': '*/*',
                       'Accept-Encoding':
                         'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization': 'Bearer 0123456789-ABCDEF',
                       'User-Agent': /wavefront.*/ })
      .to_return(status: 200, body: '', headers: {})
    cmd_to_call(word, "delete #{id}",
                method: :delete, path: "/api/v2/#{word}/#{id}")
  end

  cmd_to_call(word, "undelete #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/undelete")
  cmd_to_call(word, "snooze #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/snooze")
  cmd_to_call(word, "search id=#{id}",
              method: :post, path: "/api/v2/search/#{word}",
              body: { limit: 10,
                      offset: 0,
                      query: [{ key: 'id',
                                value: id,
                                matchingMethod: 'EXACT' }],
                      sort: { field: 'id', ascending: true } },
              headers: JSON_POST_HEADERS)
  cmd_to_call(word, "snooze -T 800 #{id}",
              method: :post,
              path: "/api/v2/#{word}/#{id}/snooze?seconds=800")
  cmd_to_call(word, "unsnooze #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/unsnooze")
  cmd_to_call(word, "install #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/install")
  cmd_to_call(word, "uninstall #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/uninstall")
  cmd_to_call(word, 'summary', path: "/api/v2/#{word}/summary")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}", "snooze #{bad_id}",
                     "install #{bad_id}", "uninstall #{bad_id}",
                     "snooze -T 500 #{bad_id}"])
  cmd_to_call(word, 'snoozed',
              method: :post,
              path: "/api/v2/search/#{word}",
              body: search_body('snoozed'))
  cmd_to_call(word, 'firing',
              method: :post,
              path: "/api/v2/search/#{word}",
              body: search_body('firing'))
  cmd_to_call(word, 'currently firing',
              method: :post,
              path: "/api/v2/search/#{word}",
              body: search_body('firing'))
  cmd_to_call(word, 'currently in_maintenance',
              method: :post,
              path: "/api/v2/search/#{word}",
              body: search_body('in_maintenance'))
  cmd_to_call(word, 'queries', path: "/api/v2/#{word}?limit=999&offset=0")
  tag_tests(word, id, bad_id)
  noop_tests(word, id, true)
  test_list_output(word)
end

class TestAlertMethods < CliMethodTest
  def test_import_method
    import_tester(:window,
                  %i[condition displayExpression resolveAfterMinutes
                     minutes severity tags target name],
                  %i[id])
  end

  def cliclass
    WavefrontCli::Alert
  end
end
