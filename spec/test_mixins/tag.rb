# frozen_string_literal: true

module WavefrontCliTest
  #
  # Include this module to get full tag tests
  #
  module Tag
    def test_tags
      assert_repeated_output("No tags set on #{friendly_name} '#{id}'.") do
        assert_cmd_gets("tags #{id}", "/api/v2/#{api_path}/#{id}/tag")
      end

      assert_noop("tags #{id}",
                  'uri: GET https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag")
      assert_invalid_id("tags #{invalid_id}")
      assert_usage('tags')
      assert_abort_on_missing_creds("tags #{id}")
    end

    def test_tag_set
      assert_repeated_output("Set tags on #{friendly_name} '#{id}'.") do
        assert_cmd_posts("tag set #{id} mytag",
                         "/api/v2/#{api_path}/#{id}/tag",
                         %w[mytag].to_json)
      end

      assert_noop("tag set #{id} mytag",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag",
                  'body: ["mytag"]')

      assert_repeated_output("Set tags on #{friendly_name} '#{id}'.") do
        assert_cmd_posts("tag set #{id} mytag1 mytag2",
                         "/api/v2/#{api_path}/#{id}/tag",
                         %w[mytag1 mytag2].to_json)
      end

      assert_noop("tag set #{id} mytag1 mytag2",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag",
                  'body: ["mytag1","mytag2"]')

      assert_invalid_id("tag set #{invalid_id} mytag")
      assert_usage("tag set #{id}")
      assert_usage('tag set')
      assert_abort_on_missing_creds("tag set #{id} mytag")
    end

    def test_tag_add
      assert_repeated_output("Tagged #{friendly_name} '#{id}'.") do
        assert_cmd_puts("tag add #{id} mytag",
                        "/api/v2/#{api_path}/#{id}/tag/mytag",
                        nil)
      end

      assert_noop("tag add #{id} mytag",
                  'uri: PUT https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag/mytag", 'body: null')

      assert_invalid_id("tag add #{invalid_id} mytag")
      assert_usage("tag add #{id}")
      assert_usage('tag add')
      assert_abort_on_missing_creds("tag add #{id} mytag")
    end

    def test_tag_delete
      assert_repeated_output("Deleted tag from #{friendly_name} '#{id}'.") do
        assert_cmd_deletes("tag delete #{id} mytag",
                           "/api/v2/#{api_path}/#{id}/tag/mytag")
      end

      assert_noop("tag delete #{id} mytag",
                  'uri: DELETE https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag/mytag", 'body: null')

      assert_invalid_id("tag delete #{invalid_id} mytag")
      assert_usage("tag delete #{id}")
      assert_usage('tag delete')
      assert_abort_on_missing_creds("tag delete #{id} mytag")
    end

    def test_tag_clear
      assert_repeated_output("Cleared tags on #{friendly_name} '#{id}'.") do
        assert_cmd_posts("tag clear #{id}",
                         "/api/v2/#{api_path}/#{id}/tag",
                         [].to_json)
      end

      assert_noop("tag clear #{id}",
                  'uri: POST https://default.wavefront.com/api/v2/' \
                  "#{api_path}/#{id}/tag", 'body: []')

      assert_invalid_id("tag clear #{invalid_id}")
      assert_usage('tag clear')
      assert_abort_on_missing_creds("tag clear #{id}")
    end
  end
end
