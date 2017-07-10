#!/usr/bin/env ruby

require_relative '../../../../lib/wavefront-cli/display/printer/terse'
require_relative '../spec_helper'

TERSE_DATA = [{ id: 'id1', name: 'name1', fa: 1, fb: 2, fc: 3 },
              { id: 'id2', name: 'name2', fa: 11, fb: 21, fc: 31 }].freeze

# Test terse printer
#
class WavefrontDisplayPrinterTerse < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplayPrinter::Terse.new(TERSE_DATA, :id, :name)
  end

  def test_format_string
    assert_equal(wf.fmt_string, '%-3s  %-5s')
  end

  def test_longest_keys
    assert_equal(wf.longest_keys, id: 3, name: 5)
  end

  def test_prep_output_1
    x = wf.prep_output
    assert_equal(x[0], 'id1  name1')
    assert_equal(x[1], 'id2  name2')
  end

  def test_prep_output_2
    wf.instance_variable_set(:@fmt_string, '%-10s %-100s')
    wf.instance_variable_set(:@keys, %i[name fb])
    x = wf.prep_output
    assert_equal(x[0], 'name1      2')
    assert_equal(x[1], 'name2      21')
  end

  def test_prep_output_3
    wf.instance_variable_set(:@keys, %i[name nokey])
    x = wf.prep_output
    assert_equal(x[0], 'name1')
    assert_equal(x[1], 'name2')
  end
end
