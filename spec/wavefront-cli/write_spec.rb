#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/write'

# Ensure 'write' commands produce the correct API calls.
#
class WriteEndToEndTest < EndToEndTest
  def test_no_config_no_envvars_proxy_write
    skip if have_config?

    blank_envvars
    wf = WavefrontCliController

    out, err = capture_io do
      assert_raises(SystemExit) { wf.new(%w[write point test 1]) }
    end

    assert_empty(err)
    assert_match(/Credentials must contain proxy address/, out)
    assert_match(/You may also run 'wf config setup'/, out)
  end

  def _test_no_config_no_envvars_api_write
    skip if have_config?

    blank_envvars
    wf = WavefrontCliController

    out, err = capture_io do
      assert_raises(SystemExit) { wf.new(%w[write point -u api test 1]) }
    end

    assert_empty(err)
    assert_match(/Credentials must contain api token/, out)
    assert_match(/You may also run 'wf config setup'/, out)
  end

  def _test_no_config_no_envvars_local_socket_write
    skip if have_config?

    blank_envvars
    wf = WavefrontCliController

    out, err = capture_io do
      assert_raises(SystemExit) { wf.new(%w[write point -u unix test 1]) }
    end

    assert_empty(err)
    assert_match(/Credentials must contain socket file path/, out)
    assert_match(/You may also run 'wf config setup'/, out)
  end

  def _test_no_config_no_envvars_http_proxy_write
    skip if have_config?

    blank_envvars
    wf = WavefrontCliController

    out, err = capture_io do
      assert_raises(SystemExit) { wf.new(%w[write point -u http test 1]) }
    end

    assert_empty(err)
    assert_match(/Credentials must contain proxy address/, out)
    assert_match(/You may also run 'wf config setup'/, out)
  end
end
