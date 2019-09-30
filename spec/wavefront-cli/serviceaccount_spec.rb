#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/serviceaccount'

# Ensure 'serviceaccount' commands produce the correct API calls.
#
# rubocop:disable Metrics/ClassLength
class ServiceAccountEndToEndTest < EndToEndTest
  include WavefrontCliTest::Describe
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::Search

  def test_list
    quietly do
      assert_cmd_gets('list', '/api/v2/account/serviceaccount')
    end

    assert_noop(
      'list',
      'uri: GET https://default.wavefront.com/api/v2/account/serviceaccount'
    )
    assert_abort_on_missing_creds('list')
  end

  def test_groups
    quietly do
      assert_cmd_gets("groups #{id}", "/api/v2/#{api_path}/#{id}")
    end

    assert_invalid_id("groups #{invalid_id}")
    assert_usage('groups')

    assert_noop(
      "groups #{id}",
      "uri: GET https://default.wavefront.com/api/v2/#{api_path}/#{id}"
    )

    assert_abort_on_missing_creds("groups #{id}")
  end

  def test_permissions
    quietly do
      assert_cmd_gets("permissions #{id}", "/api/v2/#{api_path}/#{id}")
    end

    assert_invalid_id("permissions #{invalid_id}")
    assert_usage('permissions')

    assert_noop(
      "permissions #{id}",
      "uri: GET https://default.wavefront.com/api/v2/#{api_path}/#{id}"
    )

    assert_abort_on_missing_creds("permissions #{id}")
  end

  def test_activate
    assert_repeated_output("Activated service account 'sa::test-id'.") do
      assert_cmd_posts("activate #{id}",
                       "/api/v2/account/serviceaccount/#{id}/activate")
    end

    assert_invalid_id("activate #{invalid_id}")
    assert_abort_on_missing_creds("activate #{id}")
    assert_usage('activate')
  end

  def test_deactivate
    assert_repeated_output("Deactivated service account 'sa::test-id'.") do
      assert_cmd_posts("deactivate #{id}",
                       "/api/v2/account/serviceaccount/#{id}/deactivate")
    end

    assert_invalid_id("deactivate #{invalid_id}")
    assert_abort_on_missing_creds("deactivate #{id}")
    assert_usage('deactivate')
  end

  def test_create_without_options
    quietly do
      assert_cmd_posts("create #{id}",
                       '/api/v2/account/serviceaccount',
                       identifier: id,
                       active: true,
                       groups: [],
                       tokens: [],
                       userGroups: [])
    end

    assert_noop(
      "create #{id}",
      'uri: POST https://default.wavefront.com/api/v2/account/serviceaccount',
      'body: ' + { identifier: id,
                   active: true,
                   groups: [],
                   tokens: [],
                   userGroups: [] }.to_json
    )

    assert_abort_on_missing_creds("create #{id}")
    assert_usage('create')
  end

  def test_create_inactive_account_with_description
    quietly do
      assert_cmd_posts("create -d words -I #{id}",
                       '/api/v2/account/serviceaccount',
                       identifier: id,
                       description: 'words',
                       active: false,
                       groups: [],
                       tokens: [],
                       userGroups: [])
    end
  end

  def test_create_account_in_usergroups
    quietly do
      assert_cmd_posts("create -g #{usergroups[0]} -g #{usergroups[1]} #{id}",
                       '/api/v2/account/serviceaccount',
                       identifier: id,
                       active: true,
                       groups: [],
                       tokens: [],
                       userGroups: usergroups)
    end
  end

  def test_create_account_with_tokens
    quietly do
      assert_cmd_posts("create -k #{tokens[0]} -k #{tokens[1]} #{id}",
                       '/api/v2/account/serviceaccount',
                       identifier: id,
                       active: true,
                       groups: [],
                       tokens: tokens,
                       userGroups: [])
    end
  end

  def test_create_account_with_permissions
    quietly do
      assert_cmd_posts("create -p #{permissions[0]} -p #{permissions[1]} #{id}",
                       '/api/v2/account/serviceaccount',
                       identifier: id,
                       active: true,
                       groups: permissions,
                       tokens: [],
                       userGroups: [])
    end
  end

  def test_create_invalid_usergroup
    assert_exits_with('Unable to run command. Invalid usergroup ID.',
                      "create -g abcdefg #{id}")
  end

  def test_create_invalid_permission
    assert_exits_with('Unable to run command. Invalid permission.',
                      "create -p 123456 #{id}")
  end

  def test_create_invalid_token
    assert_exits_with('Unable to run command. Invalid API token.',
                      "create -k abcdefg #{id}")
  end

  def test_dump
    _out = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_gets('dump --format=json', '/api/v2/account/serviceaccount')
      end
    end

    assert_cannot_noop('dump --format=json')
  end

  def test_join
    assert_repeated_output(
      '2659191e-aad4-4302-a94e-9667e1517127 (Everyone)'
    ) do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).with(body: { tokens: [],
                       userGroups: usergroups,
                       groups: %w[events_management dashboard_management],
                       description: 'some information',
                       active: true,
                       identifier: 'sa::test' })
                   .to_return(body: canned_response.to_json, status: 200)

        wf.new("serviceaccount join #{id} #{usergroups[1]} " \
               "#{p[:cmdline]}".split)

        assert_requested(get_stub, times: 2)
        assert_requested(put_stub)
      end
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  def test_leave
    assert_repeated_output(
      '2659191e-aad4-4302-a94e-9667e1517127 (Everyone)'
    ) do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).to_return(
          body: { tokens: [],
                  userGroups: [{ id: usergroups[0],
                                 name: 'Everyone',
                                 permissions: [],
                                 customer: 'sysdef',
                                 properties: { nameEditable: false,
                                               permissionsEditable: true,
                                               usersEditable: false },
                                 description: 'System group' },
                               { id: usergroups[1],
                                 name: 'newgroup',
                                 permissions: [],
                                 customer: 'sysdef' }],
                  active: true,
                  groups: %w[events_management dashboard_management],
                  description: 'some information',
                  identifier: 'sa::test' }.to_json, status: 200
        )

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).with(body: { tokens: [],
                       userGroups: [usergroups[0]],
                       groups: %w[events_management dashboard_management],
                       description: 'some information',
                       active: true,
                       identifier: 'sa::test' })
                   .to_return(body: canned_response.to_json, status: 200)

        wf.new("serviceaccount leave #{id} #{usergroups[1]} " \
               "#{p[:cmdline]}".split)

        assert_requested(get_stub, times: 2)
        assert_requested(put_stub)
      end
    end
  end
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/MethodLength

  def test_grant_to
    quietly do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).with(body: { tokens: [],
                       userGroups: [usergroups[0]],
                       groups: %w[events_management
                                  dashboard_management
                                  alerts_management],
                       description: 'some information',
                       active: true,
                       identifier: 'sa::test' })
                   .to_return(body: canned_response.to_json, status: 200)

        wf.new("serviceaccount grant alerts_management to #{id} " \
               "#{p[:cmdline]}".split)

        assert_requested(get_stub, times: 2)
        assert_requested(put_stub)
      end
    end
  end

  def test_revoke_from
    quietly do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/account/serviceaccount/#{id}"
        ).with(body: { tokens: [],
                       userGroups: [usergroups[0]],
                       groups: %w[events_management],
                       description: 'some information',
                       active: true,
                       identifier: 'sa::test' })
                   .to_return(body: canned_response.to_json, status: 200)

        wf.new("serviceaccount revoke dashboard_management from #{id} " \
               "#{p[:cmdline]}".split)

        assert_requested(get_stub, times: 2)
        assert_requested(put_stub)
      end
    end
  end

  # Override this method from the set helper: we don't pass an ID with service
  # accounts

  def _set_put_stub(perm)
    stub_request(:put, "https://#{perm[:endpoint]}/api/v2/#{api_path}/#{id}")
      .with(body: { set_key => 'new_value' },
            headers: mk_headers(perm[:token]))
      .to_return(status: 200, body: '', headers: {})
  end

  private

  def id
    'sa::test-id'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'serviceaccount'
  end

  def api_path
    'account/serviceaccount'
  end

  def search_api_path
    'serviceaccount'
  end

  def sdk_class_name
    'ServiceAccount'
  end

  def friendly_name
    'service account'
  end

  def permissions
    %w[alerts_management events_management]
  end

  def tokens
    %w[3d986e9e-9ab7-492b-89d5-15bb38d95674
       30cac18a-4ebc-4204-ae09-34270d9f50e5]
  end

  def usergroups
    %w[2659191e-aad4-4302-a94e-9667e1517127
       abcdef12-1234-abcd-1234-abcdef012345]
  end

  def import_fields
    %i[identifier description active tokens groups userGroups]
  end

  def set_key
    'description'
  end

  def canned_response
    { tokens: [],
      userGroups: [{ id: usergroups[0],
                     name: 'Everyone',
                     permissions: [],
                     customer: 'sysdef',
                     properties: { nameEditable: false,
                                   permissionsEditable: true,
                                   usersEditable: false },
                     description: 'System group which contains all users' }],
      active: true,
      groups: %w[events_management dashboard_management],
      description: 'some information',
      identifier: 'sa::test' }
  end
end
# rubocop:enable Metrics/ClassLength
