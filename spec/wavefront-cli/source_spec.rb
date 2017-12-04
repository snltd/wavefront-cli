#!/usr/bin/env ruby

id = '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
bad_id = '(>_<)'
word = 'source'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "clear #{id}"])
  cmd_to_call(word, 'list', path: "/api/v2/#{word}")
  cmd_to_call(word, 'list -L 50', path: "/api/v2/#{word}?limit=50")
  cmd_to_call(word, 'list -L 100 -o mysource',
              path: "/api/v2/#{word}?cursor=mysource&limit=100")
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "clear #{id}",
              method: :delete, path: "/api/v2/#{word}/#{id}")
  invalid_ids(word, ["describe #{bad_id}", "clear #{bad_id}"])
  tag_tests(word, id, bad_id)
  cmd_to_call(word, "search -f json id^#{id}",
              method: :post, path: "/api/v2/search/#{word}",
              body:   { limit: 10,
                        offset: 0,
                        query: [{ key: 'id',
                                  value: id,
                                  matchingMethod: 'STARTSWITH' }],
                        sort: { field: 'id', ascending: true } },
              headers: JSON_POST_HEADERS)
end
