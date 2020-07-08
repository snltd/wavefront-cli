#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/account'

# Ensure 'account' commands produce the correct API calls.
#
class AccountEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Search

  def test_role_add_to
    quietly do
      assert_cmd_posts("role add to #{id} #{roles.join(' ')}",
                       "/api/v2/account/#{id}/addRoles",
                       roles.to_json)
    end

    assert_invalid_id("role add to #{invalid_id} #{roles.first}")
    assert_invalid_id("role add to #{id} #{invalid_role}")
    assert_abort_on_missing_creds("role add to #{id} #{roles.last}")
    assert_usage("role add to #{roles.first}")
  end

  def test_role_remove_from
    quietly do
      assert_cmd_posts("role remove from #{id} #{roles.join(' ')}",
                       "/api/v2/account/#{id}/removeRoles",
                       roles.to_json)
    end

    assert_invalid_id("role remove from #{invalid_id} #{roles.first}")
    assert_abort_on_missing_creds("role remove from #{id} #{roles.last}")
    assert_usage("role remove from #{roles.first}")
  end

  def test_add_group_to
    assert_repeated_output("Added '#{id}' to '#{groups.first}'.") do
      assert_cmd_posts("group add to #{id} #{groups.first}",
                       "/api/v2/account/#{id}/addUserGroups",
                       [groups.first].to_json)
    end

    assert_invalid_id("group add to #{id} #{invalid_group}")
    assert_invalid_id("group add to #{invalid_id} #{groups.first}")
    assert_abort_on_missing_creds("group add to #{id} #{groups.last}")
    assert_usage("group add to #{groups.first}")
  end

  def test_remove_group_from
    assert_repeated_output("Removed '#{id}' from '#{groups.first}', " \
                           "'#{groups.last}'.") do
      assert_cmd_posts("group remove from #{id} #{groups.join(' ')}",
                       "/api/v2/account/#{id}/removeUserGroups",
                       groups.to_json)
    end

    assert_invalid_id("group remove from #{id} #{invalid_group}")
    assert_invalid_id("group remove from #{invalid_id} #{groups.first}")
    assert_abort_on_missing_creds("group remove from #{id} #{groups.last}")
    assert_usage("group remove from #{groups.first}")
  end

  def test_business_functions
    quietly do
      assert_cmd_gets("business functions #{id}",
                      "/api/v2/account/#{id}/businessFunctions")
    end

    assert_noop("business functions #{id}",
                'uri: GET https://default.wavefront.com/api/v2/account/' \
                "#{id}/businessFunctions")
    assert_invalid_id("business functions #{invalid_id}")
    assert_abort_on_missing_creds("business functions #{id}")
    assert_usage('business functions')
  end

  def test_grant_to
    assert_repeated_output("Granted '#{permission}' to '#{id}'.") do
      assert_cmd_posts("grant #{permission} to #{id}",
                       "/api/v2/account/grant/#{permission}",
                       [id].to_json)
    end

    assert_invalid_id("grant #{permission} to #{invalid_id}")
    assert_abort_on_missing_creds("grant #{permission} to #{id}")
    assert_usage("grant #{permission}")
  end

  def test_revoke_from
    assert_repeated_output("Revoked '#{permission}' from '#{id}'.") do
      assert_cmd_posts("revoke #{permission} from #{id}",
                       "/api/v2/account/revoke/#{permission}",
                       [id].to_json)
    end

    out, err = capture_io do
      assert_raises(SystemExit) do
        wf.new("account revoke #{invalid_permission} from #{id}".split)
      end
    end

    assert_empty out
    assert_equal("'made_up_permission' is not a valid Wavefront permission.",
                 err.strip)

    assert_invalid_id("revoke #{permission} from #{invalid_id}")
    assert_abort_on_missing_creds("revoke #{permission} from #{id}")
    assert_usage("revoke #{permission}")
  end

  def test_roles
    assert_repeated_output("'#{id}' has no roles.") do
      assert_cmd_gets("roles #{id}", "/api/v2/account/#{id}", [])
    end

    assert_abort_on_missing_creds("roles #{id}")
    assert_invalid_id("roles #{invalid_id}")
    assert_usage('roles')
  end

  def test_add_ingestionpolicy_to
    assert_repeated_output("Added '#{policy}' to '#{id}'.") do
      assert_cmd_posts("ingestionpolicy add to #{id} #{policy}",
                       '/api/v2/account/addingestionpolicy',
                       { ingestionPolicyId: policy,
                         accounts: [id] }.to_json)
    end

    assert_invalid_id("ingestionpolicy add to #{invalid_id} #{policy}")
    assert_invalid_id("ingestionpolicy add to #{id} #{invalid_policy}")
    assert_abort_on_missing_creds("ingestionpolicy add to #{id} #{policy}")
    assert_usage("ingestionpolicy add to #{policy}")
  end

  def test_remove_ingestionpolicy_remove
    assert_repeated_output("Removed '#{policy}' from '#{id}'.") do
      assert_cmd_posts("ingestionpolicy remove from #{id} #{policy}",
                       '/api/v2/account/removeingestionpolicies',
                       { ingestionPolicyId: policy,
                         accounts: [id] }.to_json)
    end

    assert_invalid_id("ingestionpolicy remove from #{invalid_id} #{policy}")
    assert_invalid_id("ingestionpolicy remove from #{id} #{invalid_policy}")
    assert_abort_on_missing_creds("ingestionpolicy remove from #{id} #{policy}")
    assert_usage("ingestionpolicy remove from #{policy}")
  end

  def test_ingestionpolicy
    assert_repeated_output("'#{id}' has no ingestion policy.") do
      assert_cmd_gets("ingestionpolicy #{id}", "/api/v2/account/#{id}", [])
    end

    assert_abort_on_missing_creds("ingestionpolicy #{id}")
    assert_invalid_id("ingestionpolicy #{invalid_id}")
    assert_usage('ingestionpolicy')
  end

  def test_groups
    assert_repeated_output("'#{id}' does not belong to any groups.") do
      assert_cmd_gets("groups #{id}", "/api/v2/account/#{id}", [])
    end

    assert_invalid_id("groups #{invalid_id}")
    assert_abort_on_missing_creds("groups #{id}")
    assert_usage('groups')
  end

  def test_permissions
    assert_repeated_output("'#{id}' does not have any permissions " \
                           'directly attached.') do
      assert_cmd_gets("permissions #{id}", "/api/v2/account/#{id}", [])
    end

    assert_abort_on_missing_creds("permissions #{id}")
    assert_invalid_id("permissions #{invalid_id}")
    assert_usage('permissions')
  end

  def test_invite_with_group
    expected_body = [{ emailAddress: id,
                       userGroups: [groups.first],
                       groups: [] }].to_json

    assert_repeated_output("Sent invitation to '#{id}'.") do
      assert_cmd_posts("invite user -g #{groups.first} #{id}",
                       '/api/v2/account/user/invite',
                       expected_body)
    end

    assert_noop("invite user -g #{groups.first} #{id}",
                'uri: POST https://default.wavefront.com/api/v2/account/user' \
                '/invite',
                "body: #{expected_body}")
    assert_invalid_id("invite user -g #{groups.first} #{invalid_id}")
    assert_abort_on_missing_creds("invite user -g #{groups.first} #{id}")
    assert_usage('invite user')
  end

  def test_invite_with_role_and_policy
    expected_body = [{ emailAddress: id,
                       roles: roles,
                       ingestionPolicyId: policy,
                       groups: [] }].to_json

    assert_repeated_output("Sent invitation to '#{id}'.") do
      assert_cmd_posts(
        "invite user -r #{roles.join(' -r ')} -i #{policy} #{id}",
        '/api/v2/account/user/invite',
        expected_body
      )
    end

    assert_noop("invite user -r #{roles.join(' -r ')} -i #{policy} #{id}",
                'uri: POST https://default.wavefront.com/api/v2/account/user' \
                '/invite',
                "body: #{expected_body}")
    assert_invalid_id("invite user -m #{permission} #{invalid_id}")
    assert_abort_on_missing_creds("invite user -m #{permission} #{id}")
    assert_usage('invite user')
  end

  def test_validate
    cmd = "validate #{user_list.join(' ')}"

    quietly do
      assert_cmd_posts(cmd,
                       '/api/v2/account/validateAccounts',
                       user_list.to_json,
                       IO.read(RES_DIR + 'responses' + 'user-validate.json'))
    end

    assert_noop(cmd,
                'uri: POST https://default.wavefront.com/api/v2/account' \
                '/validateAccounts',
                "body: #{user_list.to_json}")
    assert_abort_on_missing_creds(cmd)
    assert_usage('validate')
  end

  private

  def id
    'someone@example.com'
  end

  def invalid_id
    'bad' * 200
  end

  def cmd_word
    'account'
  end

  def groups
    %w[2659191e-aad4-4302-a94e-9667e1517127
       abcdef12-1234-abcd-1234-abcdef012345]
  end

  def invalid_group
    '__bad_group__'
  end

  def roles
    %w[87654321-aad4-4302-a94e-9667e1517127
       12345678-1234-abcd-1234-abcdef012345]
  end

  def invalid_role
    '__bad_role__'
  end

  def list_response
    { items: [{ identifier: 'user1@example.com' },
              { identifier: 'user2@example.com' }] }.to_json
  end

  def permission
    'alerts_management'
  end

  def invalid_permission
    'made_up_permission'
  end

  def user_list
    %w[someone@example.com
       sa:testsysacct
       no-such-thing]
  end

  def policy
    'test-policy-1579802191234'
  end

  def invalid_policy
    '__some_nonsense_or_other__'
  end
end
