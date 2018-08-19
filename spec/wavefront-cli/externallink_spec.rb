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

  cmd_to_call(word, "describe #{id}", { path: "/api/v2/extlink/#{id}" }, k)

  cmd_to_call(word, "delete #{id}",
              { method: :delete, path: "/api/v2/extlink/#{id}" }, k)

  invalid_ids(word, ["describe #{bad_id}", "delete #{bad_id}"])

  cmd_to_call(word, "search -L 100 id~#{id}",
              { method: :post,
                path:   '/api/v2/search/externallink',
                body:   { limit: '100',
                          offset: 0,
                          query: [{ key: 'id',
                                    value: id,
                                    matchingMethod: 'CONTAINS' }],
                          sort: { field: 'id', ascending: true } },
                headers: JSON_POST_HEADERS }, WavefrontCli::ExternalLink)

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
end
