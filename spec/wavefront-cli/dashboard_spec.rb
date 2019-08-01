#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../test_mixins/acl'
require_relative '../test_mixins/tag'
require_relative '../test_mixins/history'
require_relative '../../lib/wavefront-cli/dashboard'

# Ensure 'dashboard' commands produce the correct API calls.
#
class DashboardEndToEndTest < EndToEndTest
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::DeleteUndelete
  include WavefrontCliTest::Dump
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Search
  include WavefrontCliTest::Tag
  include WavefrontCliTest::History
  include WavefrontCliTest::Acl

  def test_queries
    quietly do
      assert_cmd_gets('queries', '/api/v2/dashboard?limit=999&offset=0')
    end
  end

  def test_favs
    assert_repeated_output('No favourites.') do
      assert_cmd_posts('favs', '/api/v2/search/dashboard',
                       { limit:  999,
                         offset: 0,
                         query:  [{ key:             'favorite',
                                    value:           'true',
                                    matchingMethod: 'EXACT',
                                    negated:         false }],
                         sort:   { field:     'id',
                                   ascending: true } }.to_json)
    end
  end

  def test_fav
    assert_repeated_output('No favourites.') do
      all_permutations do |perm|
        stub_request(:post, "https://#{perm[:endpoint]}/api/v2/search" \
                     '/dashboard')
          .with(body: { limit: 999,
                        offset: 0,
                        query: [{ key: 'favorite',
                                  value: 'true',
                                  matchingMethod: 'EXACT',
                                  negated: false }],
                        sort: { field: 'id', ascending: true } },
                headers: mk_headers(perm[:token]))
          .to_return(status: 200, body: '', headers: {})

        stub_request(:post,
                     "https://#{perm[:endpoint]}/api/v2/dashboard/" \
                     'test_dashboard/favorite')
          .with(body: 'null',
                headers: mk_headers(perm[:token]))
          .to_return(status: 200, body: '', headers: {})

        wf.new("#{cmd_word} fav #{id} #{perm[:cmdline]}".split)
      end
    end
  end

  def test_unfav
    assert_repeated_output('No favourites.') do
      all_permutations do |perm|
        stub_request(
          :post,
          "https://#{perm[:endpoint]}/api/v2/search/dashboard"
        )
          .with(body: { limit: 999,
                        offset: 0,
                        query: [{ key: 'favorite',
                                  value: 'true',
                                  matchingMethod: 'EXACT',
                                  negated: false }],
                        sort: { field: 'id', ascending: true } },
                headers: mk_headers(perm[:token]))
          .to_return(status: 200, body: '', headers: {})

        stub_request(
          :post,
          "https://#{perm[:endpoint]}/api/v2/dashboard/test_dashboard" \
          '/unfavorite'
        )
          .with(
            body: 'null',
            headers: mk_headers(perm[:token])
          )
          .to_return(status: 200, body: '', headers: {})

        wf.new("#{cmd_word} unfav #{id} #{perm[:cmdline]}".split)
      end
    end
  end

  private

  def id
    'test_dashboard'
  end

  def invalid_id
    '>_<'
  end

  def cmd_word
    'dashboard'
  end

  def import_fields
    %i[description name parameters tags url creatorId sections
       parameterDetails displayDescription acl numCharts]
  end

  def import_data; end

  def update_data; end
end
