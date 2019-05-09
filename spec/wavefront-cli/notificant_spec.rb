#!/usr/bin/env ruby

id = '9wltLtYXsP8Je2kI'
bad_id = '__bad_id__'
word = 'notificant'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ['list',
                       "describe #{id}",
                       'import file',
                       "delete #{id}",
                       "test #{id}",
                       'search name=pattern'])
  invalid_ids(word, ["describe #{bad_id}",
                     "delete #{bad_id}",
                     "test #{bad_id}",
                     "update #{bad_id} key=value"])
  list_tests(word)
  cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")

  cmd_to_call(word, "search id=#{id}",
              method: :post, path: "/api/v2/search/#{word}",
              body: { limit: 10,
                      offset: 0,
                      query: [{ key: 'id',
                                value: id,
                                matchingMethod: 'EXACT' }],
                      sort: { field: 'id', ascending: true } },
              headers: JSON_POST_HEADERS)
  noop_tests(word, id)
  test_list_output(word)
end

class TestNotificantMethods < CliMethodTest
  def test_import_method
    import_tester(:notificant,
                  %i[method title creatorId triggers template],
                  %i[id])
  end

  def cliclass
    WavefrontCli::Notificant
  end
end
