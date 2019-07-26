module WavefrontCliTest
  module List
    def test_list
      assert_cmd_gets('list',
                      "/api/v2/#{api_class}?limit=100&offset=0")
      assert_cmd_gets('list -o 5 --limit 10',
                      "/api/v2/#{api_class}?limit=10&offset=5")
      assert_cmd_gets('list -L 50',
                      "/api/v2/#{api_class}?limit=50&offset=0")
      assert_cmd_gets('list --offset 60',
                      "/api/v2/#{api_class}?limit=100&offset=60")

      assert_noop(
        'list -o 5',
        "uri: GET https://default.wavefront.com/api/v2/#{api_class}",
        'params: {:offset=>"5", :limit=>100}')

      assert_abort_on_missing_creds('list')
    end
  end

  module Tag
    def test_tag
    end
  end

  module Describe
    def test_describe
      assert_cmd_gets("describe #{id}", "/api/v2/#{api_class}/#{id}")
      assert_invalid_id("describe #{invalid_id}")
      assert_usage('describe')

      assert_noop(
        "describe #{id}",
        "uri: GET https://default.wavefront.com/api/v2/#{api_class}/#{id}")

      assert_abort_on_missing_creds("describe #{id}")
    end
  end

  module Delete
    def test_delete
      assert_cmd_deletes("delete #{id}", "/api/v2/#{api_class}/#{id}")
      assert_invalid_id("delete #{invalid_id}")
      assert_usage('delete')

      assert_noop(
        "delete #{id}",
        'uri: DELETE https://default.wavefront.com/api/v2/' \
        "#{api_class}/#{id}")

      assert_abort_on_missing_creds("delete #{id}")
    end
  end

  module DeleteUndelete
    include Delete

    def test_undelete
      assert_cmd_posts("undelete #{id}",
                       "/api/v2/#{api_class}/#{id}/undelete", nil)
      assert_invalid_id("undelete #{invalid_id}")
      assert_usage('undelete')
      assert_abort_on_missing_creds("undelete #{id}")

      assert_noop(
          "undelete #{id}",
          'uri: POST https://default.wavefront.com/api/v2/' \
          "#{api_class}/#{id}/undelete",
          'body: null')
    end
  end

  module Search
    def test_search
      assert_cmd_posts("search id=#{id}",
                       "/api/v2/search/#{api_class}",
                       { limit: 10,
                         offset: 0,
                         query: [{ key: 'id',
                                   value: id,
                                   matchingMethod: 'EXACT',
                                   negated: false }],
                         sort: { field: 'id', ascending: true } })

      assert_cmd_posts("search id=#{id} thing!^word --all",
                       "/api/v2/search/#{api_class}",
                       { limit: 999,
                         offset: 0,
                         query: [{ key: 'id',
                                   value: id,
                                   matchingMethod: 'EXACT',
                                   negated: false },
                                 { key: 'thing',
                                   value: 'word',
                                   matchingMethod: 'STARTSWITH',
                                   negated: true }],
                         sort: { field: 'id', ascending: true } })


      assert_cmd_posts('search id!~avoid -L 2',
                       "/api/v2/search/#{api_class}",
                       { limit: 2,
                         offset: 0,
                         query: [{ key: 'id',
                                   value: 'avoid',
                                   matchingMethod: 'CONTAINS',
                                   negated: true }],
                         sort: { field: 'id', ascending: true } })
    end
  end

  module Dump
    def test_dump; end
  end

  module Set
    def test_set; end
  end

  module Import
    def test_import; end
  end
end
