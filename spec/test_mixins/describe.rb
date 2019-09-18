# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'describe' commands
  #
  module Describe
    def test_describe
      quietly do
        assert_cmd_gets("describe #{id}", "/api/v2/#{api_class}/#{id}")
      end

      assert_invalid_id("describe #{invalid_id}")
      assert_usage('describe')

      assert_noop(
        "describe #{id}",
        "uri: GET https://default.wavefront.com/api/v2/#{api_class}/#{id}"
      )

      assert_abort_on_missing_creds("describe #{id}")
    end
  end
end
