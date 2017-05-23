#!/usr/bin/env ruby

id = 'someone@somewhere.com'
bad_id = '__BAD__'
word = 'user'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}" ])
  cmd_to_call(word, 'list', path: "/api/v2/#{word}")
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "delete #{id}", method: :delete,
                                    path:   "/api/v2/#{word}/#{id}")
  cmd_to_call(word, "grant agent_management #{id}",
      { method: :post, path: "/api/v2/#{word}/#{id}/grant",
        body:   'group=agent_management',
        headers: JSON_POST_HEADERS })

  cmd_to_call(word, "revoke agent_management #{id}",
      { method: :post, path: "/api/v2/#{word}/#{id}/revoke",
        body:   'group=agent_management',
        headers: JSON_POST_HEADERS })

  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])
end
