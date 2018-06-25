#!/usr/bin/env ruby

word = 'derivedmetric'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

id     = '1529938767979'
bad_id = '>_<'

k = WavefrontCli::DerivedMetric

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}",
                       "undelete #{id}", "history #{id}"])
  list_tests(word, nil, k)
  cmd_to_call(word, "describe #{id}", { path: "/api/v2/#{word}/#{id}" }, k)
  cmd_to_call(word, "describe -v 7 #{id}",
              { path: "/api/v2/#{word}/#{id}/history/7" }, k)
  cmd_to_call(word, "history #{id}",
              { path: "/api/v2/#{word}/#{id}/history" }, k)

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
                {  method: :delete, path: "/api/v2/#{word}/#{id}" }, k)
  end

  cmd_to_call(word, "search id=#{id}",
              { method: :post, path: "/api/v2/search/#{word}",
                body:   { limit: 10,
                          offset: 0,
                          query: [{ key: 'id',
                                    value: id,
                                    matchingMethod: 'EXACT' }],
                          sort: { field: 'id', ascending: true } },
                headers: JSON_POST_HEADERS }, k)

  cmd_to_call(word, "undelete #{id}",
              { method: :post, path: "/api/v2/#{word}/#{id}/undelete" }, k)
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}"])
  tag_tests(word, id, bad_id, nil, k)

  cmd_to_call(word, 'create test_dm ts(series)',
              { method: :post, path: '/api/v2/derivedmetric',
                body: { minutes:            5,
                        name:               'test_dm',
                        processRateMinutes: 1,
                        query:              'ts(series)' },
                headers: JSON_POST_HEADERS }, k)

  cmd_to_call(word, 'create -i 3 -r 7 test_dm ts(series)',
              { method: :post, path: '/api/v2/derivedmetric',
                body: { minutes:            7,
                        name:               'test_dm',
                        processRateMinutes: 3,
                        query:              'ts(series)' },
                headers: JSON_POST_HEADERS }, k)

  cmd_to_call(word, 'create -i 3 -T tag1 -T tag2 test_dm ts(series)',
              { method: :post, path: '/api/v2/derivedmetric',
                body: { minutes:            5,
                        name:               'test_dm',
                        processRateMinutes: 3,
                        tags:               ['tag1', 'tag2'],
                        query:              'ts(series)' },
                headers: JSON_POST_HEADERS }, k)
end
