#!/usr/bin/env ruby

id = '1481553823153:testev'
bad_id = '__bad_id__'
word = 'event'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "create #{id}",
                       "close #{id}", "delete #{id}"])
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "create -N #{id}",
              { method: :post, path: "/api/v2/#{word}" })
  cmd_to_call(word, "close #{id}",
             { method: :post, path: "/api/v2/#{word}/#{id}/close" })
  tag_tests(word, id, bad_id)
end
