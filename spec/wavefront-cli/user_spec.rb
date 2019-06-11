#!/usr/bin/env ruby

id = 'someone@somewhere.com'
bad_id = 'b' * 600
word = 'user'
gid1 = '2659191e-aad4-4302-a94e-9667e1517127'
gid2 = 'abcdef12-1234-abcd-1234-abcdef012345'
priv = 'alerts_management'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  hdrs = JSON_POST_HEADERS.merge(
    'Content-Type': 'application/x-www-form-urlencoded'
  )

  missing_creds(word, ['list',
                       "describe #{id}",
                       "delete #{id}",
                       "create #{id}",
                       "invite #{id}",
                       "update key=val #{id}",
                       'import file',
                       "groups #{id}",
                       "join #{id} #{gid1}",
                       "leave #{id} #{gid1}",
                       "grant #{priv} to #{id}",
                       "revoke #{priv} from #{id}"])

  cmd_to_call(word, 'list', path: "/api/v2/#{word}")

  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")

  cmd_to_call(word, "create #{id}",
              method: :post,
              path:   "/api/v2/#{word}?sendEmail=false",
              body:   { emailAddress: id,
                        groups:       [],
                        userGroups:   [] }.to_json)

  cmd_to_call(word, "create -e #{id} -m #{priv}",
              method: :post,
              path:   "/api/v2/#{word}?sendEmail=true",
              body:   { emailAddress: id,
                        groups:       [priv],
                        userGroups:   [] }.to_json)

  cmd_to_call(word, "create #{id} -g #{gid1} -g #{gid2}",
              method: :post,
              path:   "/api/v2/#{word}?sendEmail=false",
              body:   { emailAddress: id,
                        groups:       [],
                        userGroups:   [gid1, gid2] }.to_json)

  cmd_to_call(word, "invite -m #{priv} -g #{gid2} #{id}",
              method: :post,
              path:   "/api/v2/#{word}/invite",
              body:   [{ emailAddress: id,
                         groups:       [priv],
                         userGroups:   [gid2] }].to_json)

  cmd_to_call(word, "delete #{id}",
              method: :post,
              path:   "/api/v2/#{word}/deleteUsers",
              body:   [id].to_json)

  cmd_to_call(word, "groups #{id}", path: "/api/v2/#{word}/#{id}")

  cmd_to_call(word, "join #{id} #{gid1}",
              method: :post,
              path:   "/api/v2/#{word}/#{id}/addUserGroups",
              body:   [gid1].to_json)

  cmd_to_call(word, "leave #{id} #{gid2} #{gid1}",
              method: :post,
              path:   "/api/v2/#{word}/#{id}/removeUserGroups",
              body:   [gid2, gid1].to_json)

  cmd_to_call(word, "grant agent_management to #{id}",
              method: :post,
              path: "/api/v2/#{word}/#{id}/grant",
              body:   'group=agent_management',
              headers: hdrs)

  cmd_to_call(word, "revoke agent_management from #{id}",
              method: :post,
              path: "/api/v2/#{word}/#{id}/revoke",
              body:   'group=agent_management',
              headers: hdrs)

  search_tests(word, id)

  invalid_ids(word, ["describe #{bad_id}",
                     "delete #{bad_id}",
                     "delete #{id} #{bad_id}",
                     "delete #{bad_id}",
                     "invite #{bad_id}",
                     "create -e #{bad_id}",
                     "groups #{bad_id}",
                     "join #{bad_id} #{gid1}",
                     "leave #{bad_id} #{gid1}",
                     "grant #{priv} to #{bad_id}",
                     "revoke #{priv} from #{bad_id}"])

  cmd_noop(word, 'list',
           ["GET https://metrics.wavefront.com/api/v2/#{word}"])
  cmd_noop(word, 'describe rob@a.com',
           ["GET https://metrics.wavefront.com/api/v2/#{word}/rob@a.com"])
  test_list_output(word)
end
