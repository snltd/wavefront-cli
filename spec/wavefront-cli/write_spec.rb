#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/write'

# Ensure 'write' commands produce the correct API calls.
#
class WriteEndToEndTest < EndToEndTest
  def test_write_point_via_api
    out, err = capture_io do
      assert_cmd_posts('-u api -H tester point test.path 1',
                      '/report?f=wavefront',
                      'test.path 1.0 source=tester',
                      nil,
                      'Content-Type': 'application/octet-stream')
    end

    assert_empty(err)
    assert_match(/ sent 1$/, out)
    assert_match(/ rejected 0$/, out)
    assert_match(/ unsent 0$/, out)

    assert_noop('-u api -H tester point test.path 1',
                'uri: POST https://default.wavefront.com/report',
                'body: test.path 1.0 source=tester')

    assert_usage('write point test.path')
    assert_usage('write point')
  end

  def test_write_point_via_api_fail
    bad_response = { status: { result: 'OK', message: '', code: 200 },
                     items: [] }.to_json

      assert_cmd_posts('-u api -H tester point test.path 1',
                      '/report?f=wavefront',
                      'test.path 1.0 source=tester',
                      bad_response,
                      'Content-Type': 'application/octet-stream')
  end

  def _test_create_without_options
    quietly do
      assert_cmd_posts('create myname mydescription mytemplate',
                       '/api/v2/extlink',
                       name: 'myname',
                       template: 'mytemplate',
                       description: 'mydescription')
    end

    assert_noop('create myname mydescription mytemplate',
                'uri: POST https://default.wavefront.com/api/v2/extlink',
                'body: ' + { name: 'myname',
                             template: 'mytemplate',
                             description: 'mydescription' }.to_json)

    assert_abort_on_missing_creds('create myname mydescription mytemplate')
    assert_usage('create myname mydescription')
    assert_usage('create myname')
  end

  private

  def cmd_word
    'write'
  end

  def api_path
    'extlink'
  end
end
