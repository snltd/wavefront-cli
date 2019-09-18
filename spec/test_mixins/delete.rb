# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'delete' commands.
  #
  module Delete
    def test_delete
      assert_repeated_output("Deleted #{friendly_name} '#{id}'.") do
        assert_cmd_deletes("delete #{id}", "/api/v2/#{api_class}/#{id}")
      end

      assert_invalid_id("delete #{invalid_id}")
      assert_usage('delete')

      assert_noop(
        "delete #{id}",
        'uri: DELETE https://default.wavefront.com/api/v2/' \
        "#{api_class}/#{id}"
      )

      assert_abort_on_missing_creds("delete #{id}")
    end
  end
end
