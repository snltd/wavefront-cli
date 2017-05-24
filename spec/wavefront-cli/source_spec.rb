#!/usr/bin/env ruby

id = '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
bad_id = '(>_<)'
word = 'source'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}"])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "delete #{id}",
              method: :delete, path: "/api/v2/#{word}/#{id}")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])
  tag_tests(word, id, bad_id)
end
