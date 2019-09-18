# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'list' commands
  #
  module List
    def test_list
      quietly do
        assert_cmd_gets('list',
                        "/api/v2/#{api_class}?limit=100&offset=0")
        assert_cmd_gets('list -o 5 --limit 10',
                        "/api/v2/#{api_class}?limit=10&offset=5")
        assert_cmd_gets('list -L 50',
                        "/api/v2/#{api_class}?limit=50&offset=0")
        assert_cmd_gets('list --offset 60',
                        "/api/v2/#{api_class}?limit=100&offset=60")
      end

      assert_noop(
        'list -o 5',
        "uri: GET https://default.wavefront.com/api/v2/#{api_class}",
        'params: {:offset=>"5", :limit=>100}'
      )

      assert_abort_on_missing_creds('list')
    end
  end
end
