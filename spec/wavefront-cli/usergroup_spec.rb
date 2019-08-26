#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/usergroup'

# Ensure 'usergroup' commands produce the correct API calls.
#
class UserGroupEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Set
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Search

  def test_create
    quietly do
      assert_cmd_posts("create #{groupname}",
                       '/api/v2/usergroup',
                       name: groupname, permissions: [])
    end

    assert_abort_on_missing_creds("create #{groupname}")
    assert_usage('create')
  end

  def test_create_with_privileges
    quietly do
      assert_cmd_posts("create -p #{privileges[0]} -p #{privileges[1]} " \
                       "#{groupname}",
                       '/api/v2/usergroup',
                       name: groupname, permissions: privileges)
    end
  end

  def test_users
    assert_repeated_output("No users in group '#{id}'.") do
      assert_cmd_gets("users #{id}", "/api/v2/usergroup/#{id}")
    end

    assert_abort_on_missing_creds("users #{id}")
    assert_invalid_id("users #{invalid_id}")
    assert_usage('users')
  end

  def test_permissions
    assert_repeated_output("Group '#{id}' has no permissions.") do
      assert_cmd_gets("permissions #{id}", "/api/v2/usergroup/#{id}")
    end

    assert_abort_on_missing_creds("permissions #{id}")
    assert_invalid_id("permissions #{invalid_id}")
    assert_usage('permissions')
  end

  def test_add_user
    assert_repeated_output("Added '#{users[0]}' to '#{id}'.") do
      assert_cmd_posts("add user #{id} #{users[0]}",
                       "/api/v2/usergroup/#{id}/addUsers",
                       [users[0]].to_json)
    end

    assert_abort_on_missing_creds("add user #{id} #{users[0]}")
    assert_invalid_id("add user #{invalid_id} #{users[0]}")
  end

  def test_add_multiple_users
    assert_repeated_output(
      "Added '#{users[0]}', '#{users[1]}' to '#{id}'."
    ) do
      assert_cmd_posts("add user #{id} #{users[0]} #{users[1]}",
                       "/api/v2/usergroup/#{id}/addUsers",
                       users.to_json)
    end
  end

  def test_remove_user
    assert_repeated_output("Removed '#{users[0]}' from '#{id}'.") do
      assert_cmd_posts("remove user #{id} #{users[0]}",
                       "/api/v2/usergroup/#{id}/removeUsers",
                       [users[0]].to_json)
    end

    assert_abort_on_missing_creds("remove user #{id} #{users[0]}")
    assert_invalid_id("remove user #{invalid_id} #{users[0]}")
  end

  def test_remove_multiple_users
    assert_repeated_output(
      "Removed '#{users[0]}', '#{users[1]}' from '#{id}'."
    ) do

      assert_cmd_posts("remove user #{id} #{users[0]} #{users[1]}",
                       "/api/v2/usergroup/#{id}/removeUsers",
                       users.to_json)
    end
  end

  def test_grant
    assert_repeated_output(
      "Granted '#{privileges[1]}' permission to '#{id}'."
    ) do

      assert_cmd_posts("grant #{privileges[1]} to #{id}",
                       "/api/v2/usergroup/grant/#{privileges[1]}",
                       [id].to_json)
    end

    assert_abort_on_missing_creds("grant #{privileges[1]} to #{id}")
    assert_invalid_id("grant #{privileges[1]} to #{invalid_id}")
  end

  def test_revoke
    assert_repeated_output(
      "Revoked '#{privileges[0]}' permission from '#{id}'."
    ) do
      assert_cmd_posts("revoke #{privileges[0]} from #{id}",
                       "/api/v2/usergroup/revoke/#{privileges[0]}",
                       [id].to_json)
    end
  end

  private

  def id
    '2659191e-aad4-4302-a94e-9667e1517127'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'usergroup'
  end

  def sdk_class_name
    'UserGroup'
  end

  def friendly_name
    'user group'
  end

  def groupname
    'testgroup'
  end

  def privileges
    %w[alerts_management events_management]
  end

  def users
    %w[someone@somewhere.com other@elsewhere.com]
  end
end
