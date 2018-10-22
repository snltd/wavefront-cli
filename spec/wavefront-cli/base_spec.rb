#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/alert'
require 'spy'
require 'spy/integration'

OPTS = {
  endpoint: 'test.wavefront.com',
  token:    '0123456789-ABCDEF',
  debug:    false,
  noop:     true
}.freeze

OPTS_CMD = {
  endpoint: 'test.wavefront.com',
  token:    '0123456789-ABCDEF',
  debug:    false,
  noop:     true,
  test:     true,
  cmd:      true
}.freeze

DISP_DATA = {
  a: 'string',
  b: %w[list_1 list_2]
}.freeze

# Since I tidied up the file layout in wavefront-sdk, there's no
# longer a 1:1 mapping of CLI and SDK classes. wavefront-sdk/base is
# now wavefront-sdk/core/api. The only thing that broke was the
# tests in this class. Now we test the methods in the abstract base
# class via an instantiation of a concrete class. I don't think any
# of this matters.
#
class WavefrontCliBaseTest < MiniTest::Test
  attr_reader :wf, :wf_cmd

  def setup
    @wf = WavefrontCli::Alert.new(OPTS)
  end

  def test_mk_creds
    assert_equal({ endpoint: 'test.wavefront.com',
                   token:    '0123456789-ABCDEF',
                   agent:    "wavefront-cli-#{WF_CLI_VERSION}" },
                 wf.mk_creds)
  end

  def test_dispatch
    assert_raises(WavefrontCli::Exception::UnhandledCommand) { wf.dispatch }
    # assert_equal(wf_cmd.dispatch, nil)
  end
end
