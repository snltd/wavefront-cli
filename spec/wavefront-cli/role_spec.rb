#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/role'

# Ensure 'role' commands produce the correct API calls.
#
class RoleEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Search
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Set

  def test_create
    quietly do
      assert_cmd_posts("create #{role_name}",
                       '/api/v2/role',
                       name: role_name, permissions: [])
    end

    assert_abort_on_missing_creds("create #{role_name}")
    assert_usage('create')
  end

  def test_create_with_permissions
    quietly do
      assert_cmd_posts("create -p #{permissions[0]} -p #{permissions[1]} " \
                       "#{role_name}",
                       '/api/v2/role',
                       name: role_name, permissions: permissions)
    end
  end

  def test_create_with_permissions_and_description
    quietly do
      assert_cmd_posts("create -p #{permissions[0]} -p #{permissions[1]} " \
                       "-d description #{role_name}",
                       '/api/v2/role',
                       name: role_name,
                       permissions: permissions,
                       description: 'description')
    end
  end

  def test_accounts
    assert_repeated_output("No accounts have role '#{id}'.") do
      assert_cmd_posts("accounts #{id}",
                       '/api/v2/search/account',
                       {  limit: 999,
                          offset: 0,
                          query: [{ key: 'roles',
                                    value: id,
                                    matchingMethod: 'CONTAINS',
                                    negated: false }],
                          sort: { field: 'id', ascending: true } })
    end

    assert_abort_on_missing_creds("accounts #{id}")
    assert_invalid_id("accounts #{invalid_id}")
    assert_usage('accounts')
  end

  def test_groups
    assert_repeated_output("No groups have role '#{id}'.") do
      assert_cmd_posts("groups #{id}",
                       '/api/v2/search/usergroup',
                       {  limit: 999,
                          offset: 0,
                          query: [{ key: 'roles',
                                    value: id,
                                    matchingMethod: 'CONTAINS',
                                    negated: false }],
                          sort: { field: 'id', ascending: true } })
    end

    assert_abort_on_missing_creds("groups #{id}")
    assert_invalid_id("groups #{invalid_id}")
    assert_usage('groups')
  end

  def test_permissions
    assert_repeated_output("Role '#{id}' has no permissions.") do
      assert_cmd_gets("permissions #{id}",
                      "/api/v2/role/#{id}",
                      { permissions: [] }.to_json)
    end

    out, err = capture_io do
      assert_cmd_gets("permissions #{id}",
                      "/api/v2/role/#{id}",
                      { permissions: permissions }.to_json)
    end

    assert_equal(permissions, out.split("\n").uniq)
    assert_empty err

    assert_abort_on_missing_creds("permissions #{id}")
    assert_invalid_id("permissions #{invalid_id}")
    assert_usage('permissions')
  end

  def test_give_to
    assert_repeated_output("Gave '#{id}' to '#{accounts.first}'.") do
      assert_cmd_posts("give #{id} to #{accounts.first}",
                       "/api/v2/role/#{id}/addAssignees",
                       [accounts.first].to_json)
    end

    assert_abort_on_missing_creds("give #{id} to #{accounts.first}")
    assert_invalid_id("give #{invalid_id} to #{accounts.first}")
  end

  def test_take_from
    out, err = capture_io do
      assert_cmd_posts("take #{id} from #{accounts.join(' ')}",
                       "/api/v2/role/#{id}/removeAssignees",
                       accounts.to_json)
    end

    assert out.strip.tr("\n", ' ').start_with?(
      "Took '#{id}' from '#{accounts.first}', '#{accounts.last}'."
    )

    assert_empty err

    assert_abort_on_missing_creds("take #{id} from #{accounts.join(' ')}")
    assert_invalid_id("take #{invalid_id} from #{accounts.join(' ')}")
  end

  def test_grant
    assert_repeated_output(
      "Granted '#{permissions.first}' permission to '#{id}'."
    ) do
      assert_cmd_posts("grant #{permissions.first} to #{id}",
                       "/api/v2/role/grant/#{permissions.first}",
                       [id].to_json)
    end

    assert_abort_on_missing_creds("grant #{permissions.first} to #{id}")
    assert_invalid_id("grant #{permissions.first} to #{invalid_id}")
  end

  def test_revoke
    assert_repeated_output(
      "Revoked '#{permissions.last}' permission from '#{id}'."
    ) do
      assert_cmd_posts("revoke #{permissions.last} from #{id}",
                       "/api/v2/role/revoke/#{permissions.last}",
                       [id].to_json)
    end

    assert_abort_on_missing_creds("revoke #{permissions.last} from #{id}")
    assert_invalid_id("revoke #{permissions.last} from #{invalid_id}")
  end

  private

  def id
    '2659191e-aad4-4302-a94e-9667e1517127'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'role'
  end

  def role_name
    'test_role'
  end

  def permissions
    %w[alerts_management events_management]
  end

  def accounts
    %w[someone@example.com sa::testacct]
  end

  def set_key
    'description'
  end
end
