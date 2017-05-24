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
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "describe -v 7 #{id}",
              path: "/api/v2/#{word}/#{id}/history/7")
  cmd_to_call(word, "history #{id}", path: "/api/v2/#{word}/#{id}/history")
  cmd_to_call(word, "delete #{id}",
              method: :delete, path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "undelete #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/undelete")
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}"])
  tag_tests(word, id, bad_id)
end
