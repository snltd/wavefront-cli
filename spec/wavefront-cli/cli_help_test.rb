#!/usr/bin/env ruby

require_relative '../../lib/wavefront-cli'
require_relative '../spec_helper'

# Be sure the CLI behaves properly when people ask for help
#
class WavefrontCliHelpTest < MiniTest::Test
  def test_no_args
    WavefrontCommand.new([])
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Usage/, e.message)
    assert_match(/^  wavefront --version$/, e.message)
    assert_match(/^  wavefront --help$/, e.message)
  end

  def test_version
    WavefrontCommand.new(%w(--version))
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^\d+\.\d+\.\d+$/, e.message)
  end

  def test_help
    WavefrontCommand.new(%w(--help))
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Commands:$/, e.message)
    CMDS.each do |cmd|
      assert_match(/^  #{cmd} /, e.message)
    end
  end

  def test_command_help
    CMDS.each do |cmd|
      begin
        WavefrontCommand.new([cmd, '--help'])
      rescue SystemExit => e
        assert_equal(1, e.status)
        assert_match(/^Usage:/, e.message)
        assert_match(/^  #{CMD} #{cmd} /, e.message)
        assert_match(/^  #{CMD} #{cmd} --help$/, e.message)
      end
    end
  end
end
