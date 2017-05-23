#!/usr/bin/env ruby

id = 'fd248f53-378e-4fbe-bbd3-efabace8d724'
bad_id = '__bad_id__'
word = 'proxy'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}",
                       "undelete #{id}", "rename #{id} newname"])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "rename #{id} newname",
              { method: :put,
                path:   "/api/v2/#{word}/#{id}",
                body:   {name: "newname"}.to_json })
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/#{word}/#{id}" })
  cmd_to_call(word, "undelete #{id}",
              { method: :post, path: "/api/v2/#{word}/#{id}/undelete" })
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}", "rename #{bad_id} newname"])
  invalid_something(word, ["rename #{id} '(>_<)'"], 'proxy name')
end
