#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'map'
require_relative '../../../../lib/wavefront-cli/display/printer/long'
require_relative '../spec_helper'

RES_DIR = Pathname.new(__FILE__).dirname + 'resources'
LONG_DATA = Map.new(JSON.parse(IO.read(RES_DIR + 'alert_desc.json')))

DROP_FIELDS = [:conditionQBEnabled, :displayExpressionQBEnabled,
   :displayExpressionQBSerialization]

class WavefrontDisplayPrinterLong < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplayPrinter::Long.new(LONG_DATA, DROP_FIELDS)
  end

  def test_mk_line_1
    wf.instance_variable_set(:@kw, 5)
    wf.instance_variable_set(:@indent_str, '')
    assert_equal('     value', wf.mk_line('', 'value'))
    assert_equal('     value', wf.mk_line(nil, 'value'))
    assert_equal('key  value', wf.mk_line('key', 'value'))
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
    wf.mk_indent(2)
    assert_equal(wf.instance_variable_get(:@indent_str), '  ')
  end

  # def test_print_array
  # end

  #def test_two_columns
    #standard = IO.read(RES_DIR + 'describe_alert.txt')
    #assert_equal(pr.to_s, standard)
  #end
end
