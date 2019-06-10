#!/usr/bin/env ruby

require_relative '../spec_helper'

id = '4rUipOK3'
bad_id = '__BAD__'
word = 'savedsearch'
require_relative "../../lib/wavefront-cli/#{word}"
k = WavefrontCli::SavedSearch

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}"])
  list_tests(word, 'savedsearch', k)
  noop_tests(word, id, false, 'savedsearch', k)
  search_tests(word, id, k, 'savedsearch')
  cmd_to_call(word, "describe #{id}", { path: "/api/v2/#{word}/#{id}" }, k)
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/#{word}/#{id}" }, k)
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])
  test_list_output(word, k)
end
