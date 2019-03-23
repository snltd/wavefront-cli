#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/settings'

word = 'settings'

describe "#{word} command" do
  missing_creds(word, ['list permissions', 'show preferences',
                       'default usergroups'])
  cmd_to_call(word, 'list permissions',
              { path: "/api/v2/customer/permissions" })

  cmd_to_call(word, 'show preferences',
              { path: "/api/v2/customer/preferences" })

  cmd_to_call(word, 'default usergroups',
              { path: "/api/v2/customer/preferences/defaultUserGroups" })
end
