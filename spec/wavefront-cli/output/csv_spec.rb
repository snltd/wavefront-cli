#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-cli/output/csv'

# Test the CSV instantiation of the base class
#
class CsvOutputBaseTest < MiniTest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Csv.new(load_query_response, class: 'query')
  end

  def test_my_format
    assert('csv', wfo.my_format)
  end

  def test_command_class_name
    assert_equal('WavefrontCsvOutput::Query', wfo.command_class_name)
  end

  def test_command_file
    assert_equal('csv/query', wfo.command_file)
  end

  def test_command_class
    supported_commands = %w[query]

    supported_commands.each do |cmd|
      wfo = WavefrontOutput::Csv.new(load_query_response, class: cmd)
      klass = wfo.command_class
      assert_equal("WavefrontCsvOutput::#{cmd.capitalize}",
                   klass.class.name)
      assert klass.respond_to?(:run)
    end

    (CMDS - supported_commands).each do |cmd|
      wfo = WavefrontOutput::Csv.new(load_query_response, class: cmd)
      assert_raises(LoadError) { wfo.command_class }
    end
  end
end
