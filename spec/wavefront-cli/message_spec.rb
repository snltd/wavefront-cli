#!/usr/bin/env ruby

id = 'CLUSTER::IHjNaHM9'
bad_id = '(>_<)'
word = 'message'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "mark #{id}"])

  cmd_to_call(word, 'list',
              path: "/api/v2/#{word}?limit=100&offset=0&unreadOnly=true")
  cmd_to_call(word, 'list -L 50',
              path: "/api/v2/#{word}?limit=50&offset=0&unreadOnly=true")
  cmd_to_call(word, 'list -L 20 -o 8 -a',
              path: "/api/v2/#{word}?limit=20&offset=8&unreadOnly=false")
  cmd_to_call(word, 'list -a -o 60',
              path: "/api/v2/#{word}?limit=100&offset=60&unreadOnly=false")
  cmd_to_call(word, 'list -a',
              path: "/api/v2/#{word}?offset=0&limit=100&unreadOnly=false")
  cmd_to_call(word, 'list -L 50 -a',
              path: "/api/v2/#{word}?offset=0&limit=50&unreadOnly=false")
  cmd_to_call(word, "mark #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/read")
  invalid_ids(word, ["mark #{bad_id}"])
end
