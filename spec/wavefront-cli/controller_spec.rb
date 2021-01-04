#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../constants'
require_relative '../support/supported_commands'
require_relative '../../lib/wavefront-cli/controller'

# Be sure the CLI behaves properly when people ask for help
#
class WavefrontCliHelpTest < MiniTest::Test
  def test_development_mode
    refute defined?(DEVELOPMENT) if ENV['CI']
  end

  def test_no_args
    capture_io { WavefrontCliController.new([]) }
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Usage/, e.message)
    assert_match(/^  \w+ --version$/, e.message)
    assert_match(/^  \w+ --help$/, e.message)
  end

  def test_commands_no_args
    SupportedCommands.new.all.each do |cmd|
      _test_command_no_args(cmd)
    end
  end

  def _test_command_no_args(cmd)
    capture_io { WavefrontCliController.new([cmd]) }
  rescue SystemExit => e
    assert e.message.end_with?("wf #{cmd} --help")
  end

  def test_version
    capture_io { WavefrontCliController.new(%w[--version]) }
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^\d+\.\d+\.\d+$/, e.message)
  end

  def test_help
    capture_io { WavefrontCliController.new(%w[--help]) }
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Commands:$/, e.message)

    SupportedCommands.new.all.each do |cmd|
      assert_match(/^  #{cmd} /, e.message)
    end
  end

  def test_command_help
    SupportedCommands.new.all.each do |cmd|
      begin
        capture_io { WavefrontCliController.new([cmd, '--help']) }
      rescue SystemExit => e
        assert(e.message.split("\n").map(&:size).max <= TW)
        assert_equal(1, e.status)
        assert_match(/^Usage:/, e.message)
        assert_match(/^  #{CMD} #{cmd} /, e.message)
        assert_match(/^  #{CMD} #{cmd} --help$/, e.message)
        next
      end
    end
  end

  def test_malformed_config
    capture_io do
      WavefrontCliController.new(['alert', 'list',
                                  "--config=#{RES_DIR}/malformed.conf"])
    end
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert e.message.start_with?('Could not load configuration file')
  end

  def test_missing_config
    capture_io do
      WavefrontCliController.new(%w[alert list --config=/no/such/file])
    end
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_equal("Configuration file '/no/such/file' not found.", e.message)
  end
end

# To test internal methods, make a subclass with no initializer,
# so we can get at the methods without triggering one of the things
# tested above.
#
# rubocop:disable Lint/MissingSuper
class Giblets < WavefrontCliController
  def initialize; end
end
# rubocop:enable Lint/MissingSuper

# Here's the subclass
#
class GibletsTest < MiniTest::Test
  attr_reader :wfc

  def setup
    @wfc = Giblets.new
  end

  def test_sanitize_keys
    h_in = { '--help': true, stuff: false, 'key' => 'value' }
    assert_equal(wfc.sanitize_keys(h_in),
                 help: true, stuff: false, key: 'value')
  end
end
