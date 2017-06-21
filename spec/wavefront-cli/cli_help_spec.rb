#!/usr/bin/env ruby

require_relative '../../lib/wavefront-cli/controller'
require_relative '../spec_helper'

# Be sure the CLI behaves properly when people ask for help
#
class WavefrontCliHelpTest < MiniTest::Test
=begin
  def test_no_args
    WavefrontCliController.new([])
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Usage/, e.message)
    assert_match(/^  wavefront --version$/, e.message)
    assert_match(/^  wavefront --help$/, e.message)
  end

  def test_version
    WavefrontCliController.new(%w(--version))
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^\d+\.\d+\.\d+$/, e.message)
  end

  def test_help
    WavefrontCliController.new(%w(--help))
  rescue SystemExit => e
    assert_equal(1, e.status)
    assert_match(/^Commands:$/, e.message)
    CMDS.each do |cmd|
      assert_match(/^  #{cmd} /, e.message)
    end
  end
=end
  def test_command_help
    CMDS.each do |cmd|
      begin
        WavefrontCliController.new([cmd, '--help'])
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
end
