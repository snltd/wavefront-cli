#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'map'
require_relative '../../../lib/wavefront-cli/display/printer'
require_relative './spec_helper'

RES_DIR = Pathname.new(__FILE__).dirname + 'resources'

LONG_DATA = Map.new(JSON.parse(IO.read(RES_DIR + 'alert_desc.json')))
TERSE_DATA = Map.new(JSON.parse(IO.read(RES_DIR + 'proxy_list.json'),
                                symbolize_names: true))

class DisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  def setup
    @pr = WavefrontDisplay::DisplayPrinter.new
  end

  def test_key_width
    assert_equal(pr.key_width, 0)
    assert_equal(pr.key_width({ key1: 1, row2: 2, longrow: 3}), 9)
    assert_equal(pr.key_width({ key1: 1, row2: 2, longrow: 3}, 3), 10)
  end
end

class TerseDisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  #def setup
    #@pr = WavefrontDisplay::TerseDisplayPrinter.new(TERSE_DATA, :id, :name)
  #end

  def test_format_string
  end
end

class LongDisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  def setup
    @pr = WavefrontDisplay::LongDisplayPrinter.new(LONG_DATA)
  end

  def test_mk_line_1
    pr.instance_variable_set(:@kw, 5)
    pr.instance_variable_set(:@indent_str, '')
    assert_equal('     value', pr.mk_line('', 'value'))
    assert_equal('     value', pr.mk_line(nil, 'value'))
    assert_equal('key  value', pr.mk_line('key', 'value'))
  end

  def test_mk_line_2
    xp = WavefrontDisplay::LongDisplayPrinter.new(LONG_DATA)
    xp.mk_indent(2)
    xp.instance_variable_set(:@kw, 5)
    assert_equal('       value', xp.mk_line('', 'value'))
    assert_equal('       value', xp.mk_line(nil, 'value'))
    assert_equal('  key  value', xp.mk_line('key', 'value'))
  end

  def test_mk_indent
    pr.mk_indent(2)
    assert_equal(pr.instance_variable_get(:@indent_str), '  ')
  end

  #def test_print_array
  #end

  #def test_two_columns
  #end
end
