#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/maintenancewindow'

id = '1493324005091'
bad_id = '__BAD__'
k = WavefrontCli::MaintenanceWindow
word = 'window'

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}"])
  list_tests(word, 'maintenancewindow', k)
  cmd_to_call(word, "describe #{id}",
              { path: "/api/v2/maintenancewindow/#{id}" }, k)
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/maintenancewindow/#{id}" }, k)
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])
end
