# frozen_string_literal: true

module WavefrontCliTest
  #
  # Include this module to get full ACL tests
  #
  module Acl
    def test_acl
      assert_repeated_output('No data.') do
        assert_cmd_gets("acls #{id}", "/api/v2/#{api_class}/acl?id=#{id}")
      end

      assert_noop("acls #{id}",
                  'uri: GET https://default.wavefront.com/api/v2/' \
                  "#{api_class}/acl")

      assert_invalid_id("acls #{invalid_id}")
      assert_usage('acls')
      assert_abort_on_missing_creds("acls #{id}")
    end

    def test_acl_clear
      acl_stub = stub_do_acls
      id_stub = stub_everyone_id

      quietly do
        assert_cmd_puts("acl clear #{id}",
                        "/api/v2/#{api_class}/acl/set",
                        [{ entityId: id,
                           viewAcl: [],
                           modifyAcl: [everyone_id] }].to_json)
      end

      assert_cannot_noop("acl clear #{id}")

      assert_invalid_id("acl clear #{invalid_id}")
      assert_usage('acl clear')
      assert_abort_on_missing_creds("acl clear #{id}")
      acl_stub.unhook
      id_stub.unhook
    end

    def test_acl_grant_view_to_users
      stub = stub_do_acls

      quietly do
        assert_cmd_posts("acl grant view on #{id} to #{user_acl_names}",
                         "/api/v2/#{api_class}/acl/add",
                         acl_body(id, user_acls, []))
      end

      assert_noop("acl grant view on #{id} to #{user_acl_names}",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_class}/acl/add",
                  "body: #{acl_body(id, user_acls, [])}")

      assert_invalid_id("acl grant view on #{invalid_id} to user")
      assert_usage("acl grant view on #{id}")
      assert_abort_on_missing_creds(
        "acl grant view on #{invalid_id} to user"
      )
      stub.unhook
    end

    def test_acl_grant_modify_to_group
      stub = stub_do_acls

      quietly do
        assert_cmd_posts("acl grant modify on #{id} to #{group_acls.first}",
                         "/api/v2/#{api_class}/acl/add",
                         acl_body(id, [], group_acls))
      end

      assert_noop("acl grant modify on #{id} to #{group_acls.first}",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_class}/acl/add",
                  "body: #{acl_body(id, [], group_acls)}")

      assert_invalid_id("acl grant modify on #{invalid_id} to user")
      assert_usage("acl grant modify on #{id}")
      assert_abort_on_missing_creds(
        "acl grant modify on #{invalid_id} to user"
      )
      stub.unhook
    end

    def test_acl_revoke_view_from_group
      stub = stub_do_acls

      quietly do
        assert_cmd_posts("acl revoke view on #{id} from #{group_acls.first}",
                         "/api/v2/#{api_class}/acl/remove",
                         acl_body(id, group_acls, []))
      end

      assert_noop("acl revoke view on #{id} from #{group_acls.first}",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_class}/acl/remove",
                  "body: #{acl_body(id, group_acls, [])}")

      assert_invalid_id("acl revoke view on #{invalid_id} from user")
      assert_usage("acl revoke view on #{id}")
      assert_abort_on_missing_creds(
        "acl revoke view on #{invalid_id} from user"
      )
      stub.unhook
    end

    def test_acl_revoke_modify_from_user
      stub = stub_do_acls

      quietly do
        assert_cmd_posts("acl revoke modify on #{id} from #{user_acls.first}",
                         "/api/v2/#{api_class}/acl/remove",
                         acl_body(id, [], user_acls.take(1)))
      end

      assert_noop("acl revoke modify on #{id} from #{user_acls.first}",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_class}/acl/remove",
                  "body: #{acl_body(id, [], user_acls.take(1))}")

      assert_invalid_id("acl revoke modify on #{invalid_id} from user")
      assert_usage("acl revoke modify on #{id}")
      assert_abort_on_missing_creds(
        "acl revoke modify on #{invalid_id} from user"
      )
      stub.unhook
    end

    private

    def stub_everyone_id
      Spy.on_instance_method(cmd_class, :everyone_id)
         .and_return(everyone_id)
    end

    def stub_do_acls
      Spy.on_instance_method(cmd_class, :do_acls).and_return('')
    end

    def everyone_id
      'abcd-1234'
    end

    def user_acls
      %w[someone@example.com other@elsewhere.com]
    end

    def user_acl_names
      user_acls.join(' ')
    end

    # @return [Array[String]] list of group IDs for ACL testing
    #
    def group_acls
      %w[f8dc0c14-91a0-4ca9-8a2a-7d47f4db4672]
    end

    # @return [String] JSON representation of an ACL request
    #   payload
    #
    def acl_body(id, view = [], modify = [])
      [{ entityId: id, viewAcl: view, modifyAcl: modify }].to_json
    end
  end
end
