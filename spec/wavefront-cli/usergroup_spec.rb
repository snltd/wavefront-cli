#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
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
                       name: groupname, roleIDs: [])
    end

    assert_abort_on_missing_creds("create #{groupname}")
    assert_usage('create')
  end

  def test_create_with_roles
    quietly do
      assert_cmd_posts("create -r #{roles[0]} -r #{roles[1]} #{groupname}",
                       '/api/v2/usergroup',
                       name: groupname, roleIDs: roles)
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

  def test_add_user
    assert_repeated_output("Added '#{users[0]}' to '#{id}'.") do
      assert_cmd_posts("add to #{id} #{users[0]}",
                       "/api/v2/usergroup/#{id}/addUsers",
                       [users[0]].to_json)
    end

    assert_abort_on_missing_creds("add to #{id} #{users[0]}")
    assert_invalid_id("add to #{invalid_id} #{users[0]}")
  end

  # assert_repeated_output can't cope with line wrapping, and suppressing it
  # breaks other tests. Hence the `quietly` in the next three tests.
  #
  def test_add_multiple_users
    quietly do
      assert_cmd_posts("add to #{id} #{users[0]} #{users[1]}",
                       "/api/v2/usergroup/#{id}/addUsers",
                       users.to_json)
    end
  end

  def test_remove_user
    quietly do
      assert_cmd_posts("remove from #{id} #{users[0]}",
                       "/api/v2/usergroup/#{id}/removeUsers",
                       [users[0]].to_json)
    end

    assert_abort_on_missing_creds("remove from #{id} #{users[0]}")
    assert_invalid_id("remove from #{invalid_id} #{users[0]}")
  end

  def test_remove_multiple_users
    quietly do
      assert_cmd_posts("remove from #{id} #{users[0]} #{users[1]}",
                       "/api/v2/usergroup/#{id}/removeUsers",
                       users.to_json)
    end
  end

  def test_add_role
    quietly do
      assert_cmd_posts("add role #{id} #{roles[0]}",
                       "/api/v2/usergroup/#{id}/addRoles",
                       [roles[0]].to_json)
    end

    assert_abort_on_missing_creds("add role #{id} #{roles[0]}")
    assert_invalid_id("add role #{invalid_id} #{roles[0]}")
  end

  def test_add_multiple_roles
    quietly do
      assert_cmd_posts("add role #{id} #{roles[0]} #{roles[1]}",
                       "/api/v2/usergroup/#{id}/addRoles",
                       roles.to_json)
    end
  end

  def test_remove_role
    quietly do
      assert_cmd_posts("remove role #{id} #{roles[0]}",
                       "/api/v2/usergroup/#{id}/removeRoles",
                       [roles[0]].to_json)
    end

    assert_abort_on_missing_creds("remove role #{id} #{roles[0]}")
    assert_invalid_id("remove role #{invalid_id} #{roles[0]}")
  end

  def test_remove_multiple_roles
    quietly do
      assert_cmd_posts("remove role #{id} #{roles[0]} #{roles[1]}",
                       "/api/v2/usergroup/#{id}/removeRoles",
                       roles.to_json)
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

  def users
    %w[someone@somewhere.com other@elsewhere.com]
  end

  def roles
    %w[01234567-aad4-4302-a94e-9667e1517127
       abcdefab-abcd-4302-a94e-9667e1517127]
  end
end
