module WavefrontCliTest
  module Tag
    def test_tags
      assert_cmd_gets("tags #{id}", "/api/v2/#{api_class}/#{id}/tag")
      assert_invalid_id { wf.tags(invalid_id) }
    end
  end
end
