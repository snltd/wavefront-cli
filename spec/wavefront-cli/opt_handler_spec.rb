#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/opt_handler'

# Some of these tests will be skipped if you have a ~/.wavefront
# config file. CI will never have that.
#
INTERFERING_FILE = Pathname.new(ENV['HOME']) + '.wavefront'

# Test option handler class. End to end tests because the work is
# always done in the constructor
#
class OptHandlerTest < MiniTest::Test
  def test_no_opts
    x = WavefrontCli::OptHandler.new
    assert x.is_a?(WavefrontCli::OptHandler)
    assert x.opts.is_a?(Hash)
    assert x.opts.keys.include?(:endpoint)
  end

  def test_missing_config
    WavefrontCli::OptHandler.new(config: '/no/such/file')
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match("Configuration file '/no/such/file' not found.", e.message)
  end

  def test_no_config_no_env
    return if INTERFERING_FILE.exist?

    x = WavefrontCli::OptHandler.new({})
    o = x.opts
    assert x.is_a?(WavefrontCli::OptHandler)
    assert o.is_a?(Hash)
    refute o.keys.include?(:token)
    assert_equal(o[:endpoint], 'metrics.wavefront.com')
  end

  def test_no_config_env
    return if INTERFERING_FILE.exist?

    ENV['WAVEFRONT_TOKEN'] = 'abcd1234'
    ENV['WAVEFRONT_ENDPOINT'] = 'myendpoint.wavefront.com'
    x = WavefrontCli::OptHandler.new({})
    o = x.opts
    assert x.is_a?(WavefrontCli::OptHandler)
    assert o.is_a?(Hash)
    assert_equal(o[:token], 'abcd1234')
    assert_nil o[:config]
    assert_equal(o[:endpoint], 'myendpoint.wavefront.com')
    refute o.keys.include?(:proxy)
    ENV['WAVEFRONT_TOKEN'] = nil
    ENV['WAVEFRONT_ENDPOINT'] = nil
  end

  def test_default_config_no_env
    opts = { config: CF }
    x = WavefrontCli::OptHandler.new(opts)
    o = x.opts
    assert x.is_a?(WavefrontCli::OptHandler)
    assert o.is_a?(Hash)
    assert_equal(o[:token], '12345678-abcd-1234-abcd-123456789012')
    assert_equal(o[:config], CF)
    assert_equal(o[:endpoint], 'default.wavefront.com')
    assert_equal(o[:proxy], 'wavefront.localnet')
    assert_output('') { WavefrontCli::OptHandler.new(opts) }
  end

  def test_alt_config_env
    ENV['WAVEFRONT_TOKEN'] = 'abdc1234'
    ENV['WAVEFRONT_ENDPOINT'] = nil
    opts = { config: CF, profile: 'other' }
    x = WavefrontCli::OptHandler.new(opts)
    o = x.opts
    assert x.is_a?(WavefrontCli::OptHandler)
    assert o.is_a?(Hash)
    assert_equal(o[:token], 'abdc1234')
    assert_equal(o[:config], CF)
    assert_equal(o[:endpoint], 'other.wavefront.com')
    assert_equal(o[:proxy], 'otherwf.localnet')
    assert_output('') { WavefrontCli::OptHandler.new(opts) }
    ENV['WAVEFRONT_TOKEN'] = nil
    ENV['WAVEFRONT_ENDPOINT'] = nil
  end

  def test_alt_config_env_2
    ENV['WAVEFRONT_TOKEN'] = nil
    ENV['WAVEFRONT_ENDPOINT'] = 'myendpoint.wavefront.com'
    opts = { config: CF, profile: 'other' }
    x = WavefrontCli::OptHandler.new(opts)
    o = x.opts
    assert x.is_a?(WavefrontCli::OptHandler)
    assert o.is_a?(Hash)
    assert_equal(o[:token], 'abcdefab-0123-abcd-0123-abcdefabcdef')
    assert_equal(o[:config], CF)
    assert_equal(o[:endpoint], 'myendpoint.wavefront.com')
    assert_equal(o[:proxy], 'otherwf.localnet')
    assert_output('') { WavefrontCli::OptHandler.new(opts) }
    ENV['WAVEFRONT_TOKEN'] = nil
    ENV['WAVEFRONT_ENDPOINT'] = nil
  end
end
