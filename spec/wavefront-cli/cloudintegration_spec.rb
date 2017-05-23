#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/cloudintegration'

id = '3b56f61d-1a79-46f6-905c-d75a0f613d10'
bad_id = '__BAD__'
k = WavefrontCli::CloudIntegration
word = 'integration'

describe "integration command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}",
                        "undelete #{id}"])
  list_tests(word, 'cloudintegration', k)
  cmd_to_call(word, "describe #{id}",
              { path: "/api/v2/cloudintegration/#{id}" }, k)
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/cloudintegration/#{id}" }, k)
  cmd_to_call(word, "undelete #{id}",
              { method: :post,
                path:    "/api/v2/cloudintegration/#{id}/undelete" }, k)
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}",
                     "undelete #{bad_id}"])
end
