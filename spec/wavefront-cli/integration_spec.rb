#!/usr/bin/env ruby

id = 'tester'
bad_id = '%%badid%%'
word = 'integration'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "install #{id}",
                       "uninstall #{id}", "status #{id}", 'statuses',
                       'manifests'])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "install #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/install")
  cmd_to_call(word, "uninstall #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/uninstall")
  cmd_to_call(word, "status #{id}", path: "/api/v2/#{word}/#{id}/status")
  invalid_ids(word, ["describe #{bad_id}", "install #{bad_id}",
                     "uninstall #{bad_id}", "status #{bad_id}"])
end
