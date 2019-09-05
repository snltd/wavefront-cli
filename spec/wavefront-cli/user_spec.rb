#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/user'

# Ensure 'user' commands produce the correct API calls.
#
class UserGroupEndToEndTest < EndToEndTest
  include WavefrontCliTest::Search
  include WavefrontCliTest::Describe

  def test_list
    quietly do
      assert_cmd_gets('list', '/api/v2/user')
    end
    assert_noop('list',
                'uri: GET https://default.wavefront.com/api/v2/user')
    assert_abort_on_missing_creds('list')
  end

  def test_create
    out, err = capture_io do
      assert_cmd_posts(
        "create #{id}", '/api/v2/user?sendEmail=false',
        {  emailAddress: id,
           groups:       [],
           userGroups:   [] },
        { status: { result: 'OK', message: '', code: 200 },
          response: { identifier: 'test1@sysdef.xyz',
                      customer: 'sysdef',
                      groups: [],
                      userGroups:
        [{ id: '2659191e-aad4-4302-a94e-9667e1517127',
           name: 'Everyone',
           permissions: [],
           customer: 'sysdef',
           properties:
           { nameEditable: false,
             permissionsEditable: true,
             usersEditable: false },
           description: 'System group which contains all users' }] } }.to_json
      )
    end

    out = out.split("\n")
    assert_equal("Created user 'test1@sysdef.xyz'.", out[0])
    assert_equal('Permission groups', out[1])
    assert_equal('  <none>', out[2])
    assert_equal('User groups', out[3])
    assert_match(/^  Everyone \([0-9a-f\-]{36}\)$/, out.last)
    assert_empty err
  end

  def test_create_with_email_invite
    out, err = capture_io do
      assert_cmd_posts(
        "create -e #{id}", '/api/v2/user?sendEmail=true',
        {  emailAddress: id,
           groups:       [],
           userGroups:   [] },
        { status: { result: 'OK', message: '', code: 200 },
          response: { identifier: 'test1@sysdef.xyz',
                      customer: 'sysdef',
                      groups: [],
                      userGroups:
        [{ id: '2659191e-aad4-4302-a94e-9667e1517127',
           name: 'Everyone',
           permissions: [],
           customer: 'sysdef',
           properties:
           { nameEditable: false,
             permissionsEditable: true,
             usersEditable: false },
           description: 'System group which contains all users' }] } }.to_json
      )
    end

    out = out.split("\n")
    assert_equal("Created user 'test1@sysdef.xyz'.", out[0])
    assert_equal('Permission groups', out[1])
    assert_equal('  <none>', out[2])
    assert_equal('User groups', out[3])
    assert_match(/^  Everyone \([0-9a-f\-]{36}\)$/, out.last)

    assert_empty err
  end

  def test_create_with_groups
    out, err = capture_io do
      assert_cmd_posts(
        "create -g #{groups[0]} -g #{groups[1]} #{id}",
        '/api/v2/user?sendEmail=false',
        {  emailAddress: id,
           groups:       [],
           userGroups:   groups },
        { status: { result: 'OK', message: '', code: 200 },
          response: { identifier: 'test1@sysdef.xyz',
                      customer: 'sysdef',
                      groups: [],
                      userGroups:
        [{ id: '2659191e-aad4-4302-a94e-9667e1517127',
           name: 'Everyone',
           permissions: [],
           customer: 'sysdef',
           properties:
           { nameEditable: false,
             permissionsEditable: true,
             usersEditable: false },
           description: 'System group which contains all users' }] } }.to_json
      )
    end

    out = out.split("\n")
    assert_equal("Created user 'test1@sysdef.xyz'.", out[0])
    assert_equal('Permission groups', out[1])
    assert_equal('  <none>', out[2])
    assert_equal('User groups', out[3])
    assert_match(/^  Everyone \([0-9a-f\-]{36}\)$/, out.last)
    assert_empty err
  end

  def test_invite
    assert_repeated_output("Sent invitation to '#{id}'.") do
      assert_cmd_posts("invite -m #{privilege} -g #{groups[1]} #{id}",
                       '/api/v2/user/invite',
                       [{ emailAddress: id,
                          groups:       [privilege],
                          userGroups:   [groups[1]] }].to_json)
    end

    assert_invalid_id("invite -m #{privilege} #{invalid_id}")
    assert_abort_on_missing_creds("invite -m #{privilege} #{id}")
    assert_usage('invite')
  end

  def test_delete
    assert_repeated_output("Deleted '#{id}'.") do
      assert_cmd_posts("delete #{id}",
                       '/api/v2/user/deleteUsers',
                       [id].to_json)
    end

    assert_invalid_id("delete #{invalid_id}")
    assert_abort_on_missing_creds("delete #{id}")
    assert_usage('delete')
  end

  def test_groups
    assert_repeated_output('a7d26e51-cce1-4515-5ae8-1946f57ef5b3 (Everyone)') do
      assert_cmd_gets("groups #{id}", "/api/v2/user/#{id}",
                      [{ identifier: 'someone@example.com',
                         userGroups:
     [{ id: 'a7d26e51-cce1-4515-5ae8-1946f57ef5b3',
        name: 'Everyone',
        description: 'System group which contains all users' }] }].to_json)
    end

    assert_invalid_id("groups #{invalid_id}")
    assert_abort_on_missing_creds("groups #{id}")
    assert_usage('groups')
  end

  def test_join
    assert_repeated_output("Added '#{id}' to '#{groups[0]}'.") do
      assert_cmd_posts("join #{id} #{groups[0]}",
                       "/api/v2/user/#{id}/addUserGroups",
                       [groups[0]].to_json)
    end
  end

  def test_leave
    assert_repeated_output(
      "Removed '#{id}' from '#{groups[0]}', '#{groups[1]}'."
    ) do
      assert_cmd_posts("leave #{id} #{groups[0]} #{groups[1]}",
                       "/api/v2/user/#{id}/removeUserGroups",
                       groups.to_json)
    end

    assert_invalid_id("leave #{invalid_id} #{groups[0]} #{groups[1]}")
    assert_abort_on_missing_creds("leave #{id} #{groups[0]} #{groups[1]}")
    assert_usage('leave')
  end

  def test_grant
    assert_repeated_output("Granted '#{privilege}' to '#{id}'.") do
      assert_cmd_posts("grant #{privilege} to #{id}",
                       "/api/v2/user/#{id}/grant",
                       group: privilege)
    end

    assert_invalid_id("grant #{privilege} to #{invalid_id}")
    assert_abort_on_missing_creds("grant #{privilege} to #{id}")
    assert_usage("grant #{privilege}")
  end

  def test_revoke
    assert_repeated_output("Revoked '#{privilege}' from '#{id}'.") do
      assert_cmd_posts("revoke #{privilege} from #{id}",
                       "/api/v2/user/#{id}/revoke",
                       group: privilege)
    end

    assert_invalid_id("revoke #{privilege} from #{invalid_id}")
    assert_abort_on_missing_creds("revoke #{privilege} from #{id}")
    assert_usage("revoke #{privilege} #{id}")
  end

  # We have to override most of the dump tests because of the
  # fudgery that goes on in the user API class.
  #
  def test_dump_json
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets('dump --format=json', '/api/v2/user', list_response)
      end
      Spy.teardown
    end

    assert_equal('[{"items":[{"identifier":"user1@example.com"},' \
                 '{"identifier":"user2@example.com"}]}]', out.strip)
    assert_empty(err)
  end

  def test_dump_yaml
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets('dump --format=yaml', '/api/v2/user', list_response)
      end
      Spy.teardown
    end

    assert_equal("---\n- items:\n  - identifier: user1@example.com\n  " \
                 '- identifier: user2@example.com', out.strip)
    assert_empty(err)
  end

  private

  def id
    'someonesomewhere.com'
  end

  def invalid_id
    'bad' * 200
  end

  def cmd_word
    'user'
  end

  def set_id_key
    'identifier'
  end

  def groups
    %w[2659191e-aad4-4302-a94e-9667e1517127
       abcdef12-1234-abcd-1234-abcdef012345]
  end

  def list_response
    { items: [{ identifier: 'user1@example.com' },
              { identifier: 'user2@example.com' }] }.to_json
  end

  def privilege
    'alerts_management'
  end
end
