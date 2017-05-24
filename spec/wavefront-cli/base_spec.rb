#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/base'
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
  b: %w(list_1 list_2)
}.freeze

class WavefrontCliBaseTest < MiniTest::Test
  attr_reader :wf, :wf_cmd

  def setup
    @wf = WavefrontCli::Base.new(OPTS)
    @wf_cmd = WavefrontCli::Base.new(OPTS_CMD)
    wf_cmd.define_singleton_method(:do_test_cmd) { true }
  end

  def test_mk_creds
    assert_equal wf.mk_creds, endpoint: 'test.wavefront.com',
                              token:    '0123456789-ABCDEF'
  end

  def test_format_var
    assert_equal(wf.format_var, :baseformat)
  end

  def test_dispatch
    assert_raises(WavefrontCli::Exception::UnhandledCommand) { wf.dispatch }
    assert_equal(wf_cmd.dispatch, nil)
  end
end
