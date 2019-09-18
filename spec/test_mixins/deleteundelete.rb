# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'delete' and 'undelete' commands
  #
  module DeleteUndelete
    def test_soft_delete
      all_permutations { |p| soft_delete(p) }
      assert_cannot_noop("delete #{id}")
      assert_invalid_id("delete #{invalid_id}")
      assert_usage('delete')
    end

    def test_hard_delete
      all_permutations { |p| hard_delete(p) }
    end

    def test_undelete
      out, err = capture_io do
        assert_cmd_posts("undelete #{id}",
                         "/api/v2/#{api_class}/#{id}/undelete", 'null')
      end

      assert_empty(err)
      assert_equal("Undeleted #{friendly_name} '#{id}'.",
                   out.lines.first.rstrip)

      assert_invalid_id("undelete #{invalid_id}")
      assert_usage('undelete')
      assert_abort_on_missing_creds("undelete #{id}")

      assert_noop(
        "undelete #{id}",
        'uri: POST https://default.wavefront.com/api/v2/' \
        "#{api_class}/#{id}/undelete",
        'body: null'
      )

      assert_invalid_id("undelete #{invalid_id}")
      assert_usage('undelete')
    end

    private

    def soft_delete(perm)
      stub_request(:get,
                   "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(headers: mk_headers(perm[:token]))
        .to_return(object_exists_response)

      stub_request(:delete,
                   "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(headers: mk_headers(perm[:token]))
        .to_return(status: 200)

      out, err = capture_io do
        wf.new("#{cmd_word} delete #{id} #{perm[:cmdline]}".split)
      end

      assert_empty(err)
      assert_equal("Soft deleting #{friendly_name} '#{id}'\n" \
                   "Deleted #{friendly_name} '#{id}'.",
                   out.rstrip)

      assert_requested(
        :get,
        "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}"
      )
    end

    def hard_delete(perm)
      stub_request(:get,
                   "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(headers: mk_headers(perm[:token]))
        .to_return(object_deleted_response)

      stub_request(:delete,
                   "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(headers: mk_headers(perm[:token]))
        .to_return(status: 200)

      out, err = capture_io do
        wf.new("#{cmd_word} delete #{id} #{perm[:cmdline]}".split)
      end

      assert_empty(err)
      assert_equal("Permanently deleting #{friendly_name} '#{id}'\n" \
                   "Deleted #{friendly_name} '#{id}'.",
                   out.rstrip)

      assert_requested(
        :get,
        "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}"
      )
    end

    def object_exists_response
      { status: 200, headers: {} }
    end

    def object_deleted_response
      { status: 404, headers: {} }
    end
  end
end
