#!/usr/bin/env ruby

uid1 = 'someone@somewhere.com'
uid2 = 'other@elsewhere.com'
name = 'testgroup'
bad_id = '__BAD__'
word = 'usergroup'
gid1 = '2659191e-aad4-4302-a94e-9667e1517127'
priv1 = 'alerts_management'
priv2 = 'events_management'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

k = WavefrontCli::UserGroup

describe "#{word} command" do
  missing_creds(word, ['list',
                       "describe #{gid1}",
                       "create #{name}",
                       "delete #{gid1}",
                       'import file',
                       "modify key=val #{gid1}",
                       "users #{gid1}",
                       "permissions #{gid1}",
                       "add user #{gid1} #{uid1} #{uid2}",
                       "remove user #{gid1} #{uid1} #{uid2}",
                       "grant #{priv1} to #{gid1}",
                       "revoke #{priv2} from #{gid1}",
                       'search key=value'])

  list_tests(word, 'usergroup', k)

  cmd_to_call(word, "describe #{gid1}",
              { path: "/api/v2/#{word}/#{gid1}" }, k)

  cmd_to_call(word, "create #{name}",
              { method: :post,
                path:   "/api/v2/#{word}",
                body:   { name: name, permissions: [] }.to_json }, k)

  cmd_to_call(word, "create -p #{priv1} -p #{priv2} #{name}",
              { method: :post,
                path:   "/api/v2/#{word}",
                body:   { name: name,
                          permissions: [priv1, priv2] }.to_json }, k)

  cmd_to_call(word, "delete #{gid1}",
              { method: :delete, path: "/api/v2/#{word}/#{gid1}" }, k)

  cmd_to_call(word, "users #{gid1}",
              { path: "/api/v2/#{word}/#{gid1}" }, k)

  cmd_to_call(word, "permissions #{gid1}",
              { path: "/api/v2/#{word}/#{gid1}" }, k)

  cmd_to_call(word, "add user #{gid1} #{uid1}",
              { method: :post,
                path:   "/api/v2/#{word}/#{gid1}/addUsers",
                body:   [uid1].to_json }, k)

  cmd_to_call(word, "add user #{gid1} #{uid1} #{uid2}",
              { method: :post,
                path:   "/api/v2/#{word}/#{gid1}/addUsers",
                body:   [uid1, uid2].to_json }, k)

  cmd_to_call(word, "remove user #{gid1} #{uid1}",
              { method: :post,
                path:   "/api/v2/#{word}/#{gid1}/removeUsers",
                body:   [uid1].to_json }, k)

  cmd_to_call(word, "remove user #{gid1} #{uid1} #{uid2}",
              { method: :post,
                path:   "/api/v2/#{word}/#{gid1}/removeUsers",
                body:   [uid1, uid2].to_json }, k)

  cmd_to_call(word, "grant #{priv1} to #{gid1}",
              { method: :post,
                path: "/api/v2/#{word}/grant/#{priv1}",
                body:   [gid1].to_json }, k)

  cmd_to_call(word, "revoke #{priv1} from #{gid1}",
              { method: :post,
                path: "/api/v2/#{word}/revoke/#{priv1}",
                body:   [gid1].to_json }, k)

  cmd_to_call(word, 'search -L 40 id=string',
              { method: :post, path: "/api/v2/search/#{word}",
                body:   { limit:  '40',
                          offset: 0,
                          query: [{ key: 'id',
                                    value: 'string',
                                    matchingMethod: 'EXACT' }],
                          sort: { field: 'id', ascending: true } } }, k)

  invalid_ids(word, ["describe #{bad_id}",
                     "delete #{bad_id}",
                     "modify key=val #{bad_id}",
                     "users #{bad_id}",
                     "permissions #{bad_id}",
                     "add user #{bad_id} #{uid1} #{uid2}",
                     "remove user #{bad_id} #{uid1} #{uid2}",
                     "grant #{priv1} to #{bad_id}",
                     "revoke #{priv2} from #{bad_id}"])

  cmd_noop(word, 'list',
           ["GET https://metrics.wavefront.com/api/v2/#{word}"], k)
  cmd_noop(word, "describe #{gid1}",
           ["GET https://metrics.wavefront.com/api/v2/#{word}/#{gid1}"], k)
  test_list_output(word, k)
end
