#!/usr/bin/env ruby

id = '9095WaGklE8Gy3M1'
bad_id = '__BAD__'
word = 'webhook'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}"])
  list_tests(word)
  noop_tests(word, id)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "delete #{id}", method: :delete,
                                    path:   "/api/v2/#{word}/#{id}")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])
  cmd_to_call(word, "search -o 100 -L 100 id~#{id}",
              method: :post, path: "/api/v2/search/#{word}",
              body:   { limit: '100',
                        offset: '100',
                        query: [{ key: 'id',
                                  value: id,
                                  matchingMethod: 'CONTAINS' }],
                        sort: { field: 'id', ascending: true } },
              headers: JSON_POST_HEADERS)
end
