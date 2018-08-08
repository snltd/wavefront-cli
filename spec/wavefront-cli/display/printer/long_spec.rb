#!/usr/bin/env ruby

require_relative '../../../../lib/wavefront-cli/display/printer/long'
require_relative '../spec_helper'
require_relative '../../../spec_helper'

# Test verbose printing stuff
#
class WavefrontDisplayPrinterLong < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplayPrinter::Long.new({})
  end

  def test_mk_line_1
    wf.instance_variable_set(:@kw, 5)
    wf.instance_variable_set(:@indent_str, '')
    assert_equal('     value', wf.mk_line('', 'value'))
    assert_equal('     value', wf.mk_line(nil, 'value'))
    assert_equal('key  value', wf.mk_line('key', 'value'))
  end

  def test_mk_line_2
    wf = WavefrontDisplayPrinter::Long.new({})
    wf.mk_indent(2)
    wf.instance_variable_set(:@kw, 5)
    assert_equal('       value', wf.mk_line('', 'value'))
    assert_equal('       value', wf.mk_line(nil, 'value'))
    assert_equal('  key  value', wf.mk_line('key', 'value'))
  end

  def test_mk_line_3
    wf.instance_variable_set(:@kw, 7)
    wf.instance_variable_set(:@indent_str, '  ')
    assert_equal('  key    value', wf.mk_line('key', 'value'))
    assert_equal('         value', wf.mk_line(nil, 'value'))
    assert_equal('         value', wf.mk_line('', 'value'))
    assert_equal("  key    a long string which must be\n" \
                 '         folded once',
                 wf.mk_line('key', 'a long string which must be ' \
                                   'folded once', 40))
    assert_equal("  key    a very long string whose very length\n" \
                 "         means that the method is going to\n" \
                 '         have to fold it twice',
                 wf.mk_line('key', 'a very long string whose very ' \
                            'length means that the method is going to ' \
                            'have to fold it twice', 49))
  end

  def test_mk_indent
    wf.mk_indent(2)
    assert_equal(wf.instance_variable_get(:@indent_str), '  ')
  end

  def test_preen_fields
    assert_equal(wf.preen_fields({ k1: 1, k2: 2 }, [:k1]), k1: 1)
    assert_equal(wf.preen_fields(k1: 1, k2: 2), k1: 1, k2: 2)
    assert_equal(wf.preen_fields({ k1: 1, k2: 2 }, [:k3]), {})
    assert_equal(wf.preen_fields({ k1: 1, k2: 2 }, %i[k1 k2]),
                 k1: 1, k2: 2)
  end

  def test_preen_value
    assert_equal(wf.preen_value('test'), 'test')
    assert_equal(wf.preen_value('<b>test</b>'), 'test')
    assert_equal(wf.preen_value('<b>test</b> <i>test</i>'), 'test test')
  end

  def test_blank?
    assert wf.blank?('')
    assert wf.blank?([])
    assert wf.blank?({})
    refute wf.blank?('test')
    refute wf.blank?(5)
    refute wf.blank?([1, 2])
    refute wf.blank?(a: 1)
  end

  def test_parse_line_1
    assert_nil wf.parse_line(:k, [])
    spy = Spy.on(wf, :add_hash)
    wf.parse_line('key', k1: 1, k2: 2)
    assert spy.has_been_called_with?('key', k1: 1, k2: 2)
  end

  def test_parse_line_2
    spy = Spy.on(wf, :add_array)
    wf.parse_line('key', [1, 2, 3, 4])
    assert spy.has_been_called_with?('key', [1, 2, 3, 4])
  end

  def test_parse_line_3
    spy = Spy.on(wf, :add_line)
    wf.parse_line('key', 'value')
    assert spy.has_been_called_with?('key', 'value')
  end

  def test_add_array
    spy = Spy.on(wf, :add_line)
    wf.add_array('key', %w[value1 value2 value3 value4])
    assert spy.has_been_called_with?('key', 'value1')
    assert spy.has_been_called_with?(nil, 'value2')
    assert spy.has_been_called_with?(nil, 'value3')
    assert spy.has_been_called_with?(nil, 'value4')
  end

  def test_add_hash_1
    hash = { sk1: 'value1', sk2: 'value2' }
    wf.instance_variable_set(:@kw, 10)
    wf.instance_variable_set(:@indent_step, 2)
    tc_spy = Spy.on(wf, :_two_columns)
    hr_spy = Spy.on(wf, :add_rule)
    wf.add_hash('key', hash)
    assert tc_spy.has_been_called_with?([hash], 6)
    refute hr_spy.has_been_called?
  end

  def test_add_hash_2
    hash = { sk1: 'value1', sk2: 'value2' }
    wf.instance_variable_set(:@kw, 10)
    wf.instance_variable_set(:@indent_step, 2)
    tc_spy = Spy.on(wf, :_two_columns)
    hr_spy = Spy.on(wf, :add_rule)
    wf.add_hash('key', hash, 3, 1)
    assert tc_spy.has_been_called_with?([hash], 6)
    assert hr_spy.has_been_called?
  end

  def test_add_hash_3
    hash = { sk1: 'value1', sk2: 'value2' }
    wf.instance_variable_set(:@kw, 10)
    wf.instance_variable_set(:@indent_step, 2)
    tc_spy = Spy.on(wf, :_two_columns)
    hr_spy = Spy.on(wf, :add_rule)
    wf.add_hash('key', hash, 3, 2)
    assert tc_spy.has_been_called_with?([hash], 6)
    refute hr_spy.has_been_called?
  end
end
