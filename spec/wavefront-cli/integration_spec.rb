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

  cmd_to_call(word, "status #{id}", path: "/api/v2/#{word}/#{id}/status")

  cmd_to_call(word, "install #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/install")

  cmd_to_call(word, "uninstall #{id}",
              method: :post, path: "/api/v2/#{word}/#{id}/uninstall")

  cmd_to_call(word, "alert install #{id}",
              method: :post,
              path:   "/api/v2/#{word}/#{id}/install-all-alerts")

  cmd_to_call(word, "alert uninstall #{id}",
              method: :post,
              path:   "/api/v2/#{word}/#{id}/uninstall-all-alerts")

  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")

  cmd_to_call(word, "status #{id}", path: "/api/v2/#{word}/#{id}/status")

  cmd_to_call(word, 'installed', path: "/api/v2/#{word}/installed")

  cmd_to_call(word, 'manifests -f json', path: "/api/v2/#{word}/manifests")

  invalid_ids(word, ["describe #{bad_id}", "install #{bad_id}",
                     "alert install #{bad_id}",
                     "alert uninstall #{bad_id}",
                     "uninstall #{bad_id}", "status #{bad_id}"])
end
