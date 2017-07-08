#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'map'
require_relative '../../../lib/wavefront-cli/display/printer'
require_relative './spec_helper'

RES_DIR = Pathname.new(__FILE__).dirname + 'resources'

LONG_DATA = Map.new(JSON.parse(IO.read(RES_DIR + 'alert_desc.json')))
TERSE_DATA = [
  { id: 'id1', name: 'name1', fa: 1, fb: 2, fc: 3 },
  { id: 'id2', name: 'name2', fa: 11, fb: 21, fc: 31 },
]

DROP_FIELDS = [:conditionQBEnabled, :displayExpressionQBEnabled,
   :displayExpressionQBSerialization]
class DisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  def setup
    @pr = WavefrontDisplay::DisplayPrinter.new
  end

  def test_key_width
    assert_equal(pr.key_width, 0)
    assert_equal(pr.key_width(key1: 1, row2: 2, longrow: 3), 9)
    assert_equal(pr.key_width({ key1: 1, row2: 2, longrow: 3 }, 3), 10)
  end
end

class TerseDisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  def setup
    @pr = WavefrontDisplay::TerseDisplayPrinter.new(TERSE_DATA, :id, :name)
  end

  def test_format_string
    assert_equal(pr.fmt_string, '%-3s  %-5s')
  end

  def test_longest_keys
    assert_equal(pr.longest_keys, id: 3, name: 5)
  end

  def test_prep_output_1
    x = pr.prep_output
    assert_equal(x[0], 'id1  name1')
    assert_equal(x[1], 'id2  name2')
  end

  def test_prep_output_2
    pr.instance_variable_set(:@fmt_string, '%-10s %-100s')
    pr.instance_variable_set(:@keys, [:name, :fb])
    x = pr.prep_output
    assert_equal(x[0], 'name1      2')
    assert_equal(x[1], 'name2      21')
  end

  def test_prep_output_3
    pr.instance_variable_set(:@keys, [:name, :nokey])
    x = pr.prep_output
    assert_equal(x[0], 'name1')
    assert_equal(x[1], 'name2')
  end
end

class LongDisplayPrinterTest < MiniTest::Test
  attr_reader :pr

  def setup
    @pr = WavefrontDisplay::LongDisplayPrinter.new(LONG_DATA, DROP_FIELDS)
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

  # def test_print_array
  # end

  #def test_two_columns
    #standard = IO.read(RES_DIR + 'describe_alert.txt')
    #assert_equal(pr.to_s, standard)
  #end
end
