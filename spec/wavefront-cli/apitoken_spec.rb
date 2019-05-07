#!/usr/bin/env ruby

word = 'apitoken'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

id     = '17db4cc1-65f6-40a8-a1fa-6fcae460c4bd'
bad_id = 'bad_id'

k = WavefrontCli::ApiToken

describe "#{word} command" do
  missing_creds(word, ['list',
                       'create',
                       "delete #{id}",
                       "rename #{id} name"])

  invalid_ids(word, ["delete #{bad_id}", "rename #{bad_id} name"])

  cmd_to_call(word, 'list', { path: "/api/v2/#{word}" }, k)

  cmd_noop(word, 'list',
           ["GET https://metrics.wavefront.com/api/v2/#{word}"], k)
  cmd_noop(word, 'create',
           ["POST https://metrics.wavefront.com/api/v2/#{word}"], k)
  cmd_noop(word, "delete #{id}",
           ["DELETE https://metrics.wavefront.com/api/v2/#{word}/#{id}"], k)

  cmd_to_call(word, "rename #{id} newname",
              { method: :put, path: "/api/v2/#{word}/#{id}",
                body: { tokenID:   id,
                        tokenName: 'newname' },
                headers: JSON_POST_HEADERS }, k)
end
