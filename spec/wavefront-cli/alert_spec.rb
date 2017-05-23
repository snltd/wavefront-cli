#!/usr/bin/env ruby

id = '1481553823153'
bad_id = '__bad_id__'
word = 'alert'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "snooze #{id}",
                           "delete #{id}", "undelete #{id}", "history #{id}"])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "describe -v 7 #{id}",
              path: "/api/v2/#{word}/#{id}/history/7")
  cmd_to_call(word, "history #{id}", path: "/api/v2/#{word}/#{id}/history")
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/#{word}/#{id}" })
  cmd_to_call(word, "undelete #{id}",
              { method: :post, path: "/api/v2/#{word}/#{id}/undelete" })
  cmd_to_call(word, "snooze #{id}",
              { method: :post, path: "/api/v2/#{word}/#{id}/snooze" })
  cmd_to_call(word, "snooze -T 800 #{id}",
              { method: :post,
                path:   "/api/v2/#{word}/#{id}/snooze?seconds=800" })
  cmd_to_call(word, "unsnooze #{id}",
             { method: :post, path: "/api/v2/#{word}/#{id}/unsnooze" })
  cmd_to_call(word, "summary", { path: "/api/v2/#{word}/summary" })
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}", "snooze #{bad_id}",
                     "snooze -T 500 #{bad_id}"])
  tag_tests(word, id, bad_id)
end
