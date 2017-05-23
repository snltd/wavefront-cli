#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/alert'

ID = '1481553823153'.freeze
SDK_CLASS = WavefrontCli::Alert

describe 'alert command' do
  missing_creds('alert', ['list', "describe #{ID}", "snooze #{ID}",
                           "delete #{ID}", "undelete #{ID}", "history #{ID}"])
  list_tests(:alert)
  cmd_to_call("alert describe #{ID}", path: "/api/v2/alert/#{ID}")
  cmd_to_call("alert describe -v 7 #{ID}",
              path: "/api/v2/alert/#{ID}/history/7")
  cmd_to_call("alert history #{ID}", path: "/api/v2/alert/#{ID}/history")
  cmd_to_call("alert delete #{ID}",
              { method: :delete, path: "/api/v2/alert/#{ID}" })
  cmd_to_call("alert undelete #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/undelete" })
  cmd_to_call("alert snooze #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/snooze" })
  cmd_to_call("alert snooze -T 800 #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/snooze?seconds=800" })
  cmd_to_call("alert unsnooze #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/unsnooze" })
  tag_tests(:alert)
  cmd_to_call("alert summary", { path: "/api/v2/alert/summary" })
end
