module WavefrontCliTest
  #
  # Mixin to test standard 'search' commands
  #
  module Search
    def test_search_equals
      assert_repeated_output('No matches.') do
        assert_cmd_posts("search id=#{id}",
                         "/api/v2/search/#{api_class}",
                         limit:  10,
                         offset: 0,
                         query:  [{ key: 'id',
                                    value: id,
                                    matchingMethod: 'EXACT',
                                    negated: false }],
                         sort:   { field: 'id', ascending: true })
      end

      assert_noop(
        "search id=#{id}",
        "uri: POST https://default.wavefront.com/api/v2/search/#{api_class}",
        'body: ' + { limit: 10,
                     offset: 0,
                     query: [{key: 'id',
                              value: id,
                              matchingMethod: 'EXACT',
                              negated: false}],
                              sort: { field: 'id', ascending: true}
                  }.to_json)
      assert_abort_on_missing_creds("search id=#{id}")
      assert_usage('search')
    end

    def test_search_equals_with_limits
      assert_repeated_output('No matches.') do
        assert_cmd_posts("search id=#{id} -L 5 --offset 15",
                         "/api/v2/search/#{api_class}",
                         limit:  '5',
                         offset: '15',
                         query:  [{ key: 'id',
                                    value: id,
                                    matchingMethod: 'EXACT',
                                    negated: false }],
                         sort:   { field: 'id', ascending: true })
      end

      assert_abort_on_missing_creds("search id=#{id} -L 5 --offset 15")
    end

    def test_search_does_not_begin_with
      assert_repeated_output('No matches.') do
        assert_cmd_posts("search id=#{id} thing!^word --all",
                         "/api/v2/search/#{api_class}",
                         limit:  999,
                         offset: 0,
                         query:  [{ key: 'id',
                                    value: id,
                                    matchingMethod: 'EXACT',
                                    negated: false },
                                  { key: 'thing',
                                    value: 'word',
                                    matchingMethod: 'STARTSWITH',
                                    negated: true }],
                         sort:    { field: 'id', ascending: true })
      end

      assert_abort_on_missing_creds("search id=#{id} thing!^word --all")
    end

    def test_search_contains
      assert_repeated_output('No matches.') do
        assert_cmd_posts('search id!~avoid -L 2',
                         "/api/v2/search/#{api_class}",
                         limit:  '2',
                         offset: 0,
                         query:  [{ key: 'id',
                                    value: 'avoid',
                                    matchingMethod: 'CONTAINS',
                                    negated: true }],
                         sort:   { field: 'id', ascending: true })
      end

      assert_abort_on_missing_creds('search id!~avoid -L 2')
    end

    def test_search_incorrect_usage
      assert_exits_with(
        'Searches require a key, a value, and a match operator.',
        'search value -D')
    end
  end
end
