module WavefrontCliTest
  #
  # Mixin to test standard 'search' commands
  #
  module Search
    def test_search
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
    end
  end
end
