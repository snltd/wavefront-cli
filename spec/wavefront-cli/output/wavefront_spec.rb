#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'helpers'
require_relative '../../support/supported_commands'
require_relative '../../../lib/wavefront-cli/output/wavefront'

# Test the Wavefront instantiation of the base class
#
class WavefrontOutputBaseTest < Minitest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Wavefront.new(load_query_response, class: 'query')
  end

  def test_my_format
    assert('wavefront', wfo.my_format)
  end

  def test_command_class_name
    assert_equal('WavefrontWavefrontOutput::Query', wfo.command_class_name)
  end

  def test_command_file
    assert_equal('wavefront/query', wfo.command_file)
  end

  def test_command_class
    supported_commands = %w[query]

    supported_commands.each do |cmd|
      wfo = WavefrontOutput::Wavefront.new(load_query_response, class: cmd)
      klass = wfo.command_class
      assert_equal("WavefrontWavefrontOutput::#{cmd.capitalize}",
                   klass.class.name)
      assert klass.respond_to?(:run)
    end

    (SupportedCommands.new.all - supported_commands).each do |cmd|
      wfo = WavefrontOutput::Wavefront.new(load_query_response, class: cmd)
      assert_raises(LoadError) { wfo.command_class }
    end
  end
end
