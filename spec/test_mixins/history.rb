module WavefrontCliTest
  #
  # Include this module to get history and describe -v tests
  #
  module History
    def test_describe_v
      quietly do
        assert_cmd_gets("describe -v 7 #{id}",
                        "/api/v2/#{api_class}/#{id}/history/7")
      end

      assert_noop("describe --version 10 #{id}",
                  'uri: GET https://default.wavefront.com/api/v2/' \
                  "#{api_class}/#{id}/history/10")
      assert_usage('describe -v 6')
      assert_usage("describe -v #{id}")
      assert_abort_on_missing_creds("describe -v 2 #{id}")
    end

    def test_history
      assert_repeated_output('No data.') do
        assert_cmd_gets("history #{id}",
                        "/api/v2/#{api_class}/#{id}/history")
      end

      assert_noop("history #{id}",
                  'uri: GET https://default.wavefront.com/api/v2/' \
                  "#{api_class}/#{id}/history")
      assert_usage('history')
      assert_abort_on_missing_creds("history #{id}")
    end
  end
end
