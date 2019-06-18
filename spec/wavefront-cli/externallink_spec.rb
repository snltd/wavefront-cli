#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/externallink'

id     = 'lq6rPlSg2CFMSrg6'
bad_id = '__BAD__'
k      = WavefrontCli::ExternalLink
word   = 'link'

describe "#{word} command" do
  missing_creds(word, ['list', "describe #{id}", "delete #{id}"])
  list_tests(word, 'extlink', k)
  noop_tests(word, id, false, 'extlink', k)
  search_tests(word, id, k, 'extlink')
  cmd_to_call(word, "describe #{id}", { path: "/api/v2/extlink/#{id}" }, k)
  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/extlink/#{id}" }, k)
  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])

  cmd_to_call(word, 'create name description template',
              { method: :post,
                path:   '/api/v2/extlink',
                body: {
                  name:        'name',
                  template:    'template',
                  description: 'description'
                }.to_json,
                headers: JSON_POST_HEADERS },
              WavefrontCli::ExternalLink)

  cmd_to_call(word, 'create -m metricregex -s sourceregex name ' \
                    'description template',
              { method: :post,
                path:   '/api/v2/extlink',
                body: {
                  name:              'name',
                  template:          'template',
                  description:       'description',
                  metricFilterRegex: 'metricregex',
                  sourceFilterRegex: 'sourceregex'
                }.to_json,
                headers: JSON_POST_HEADERS },
              WavefrontCli::ExternalLink)

  cmd_to_call(word, 'create -p key1=reg1 -p key2=reg2 ' \
                    '-m metricregex name description template',
              { method: :post,
                path:   '/api/v2/extlink',
                body: {
                  name:              'name',
                  template:          'template',
                  description:       'description',
                  metricFilterRegex: 'metricregex',
                  pointFilterRegex: {
                    key1: 'reg1',
                    key2: 'reg2'
                  }
                }.to_json,
                headers: JSON_POST_HEADERS },
              WavefrontCli::ExternalLink)
  test_list_output(word, k)
end
