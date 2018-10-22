#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-cli/output/hcl'

# Test HCL stuff
#
class WavefrontOutputBaseTest < MiniTest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Hcl.new(load_query_response, class: 'alert')
  end

  def test_my_format
    assert('hcl', wfo.my_format)
  end

  def test_command_class_name
    assert_equal('WavefrontHclOutput::Alert', wfo.command_class_name)
  end

  def test_command_file
    assert_equal('hcl/alert', wfo.command_file)
  end

  def test_command_class
    supported_commands = %w[alert dashboard notificant]

    supported_commands.each do |cmd|
      wfo = WavefrontOutput::Hcl.new(load_query_response, class: cmd)
      klass = wfo.command_class
      assert_equal("WavefrontHclOutput::#{cmd.capitalize}",
                   klass.class.name)
      assert klass.respond_to?(:run)
    end

    (CMDS - supported_commands).each do |cmd|
      wfo = WavefrontOutput::Hcl.new(load_query_response, class: cmd)
      assert_raises(LoadError) { wfo.command_class }
    end
  end
end
