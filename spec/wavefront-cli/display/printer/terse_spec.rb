#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../support/output_tester'
require_relative '../../../../lib/wavefront-cli/display/printer/terse'

TERSE_DATA = [{ id: 'id1', name: 'name1', fa: 1, fb: 2, fc: 3 },
              { id: 'id2', name: 'name2', fa: 11, fb: 21, fc: 31 }].freeze

# Test terse printer
#
class WavefrontDisplayPrinterTerse < Minitest::Test
  attr_reader :wf, :out

  def setup
    @wf = WavefrontDisplayPrinter::Terse.new(TERSE_DATA, %i[id name])
  end

  def test_format_string
    assert_equal('%-3<id>s', wf.format_string(TERSE_DATA, [:id]))
    assert_equal('%-3<id>s  %-5<name>s',
                 wf.format_string(TERSE_DATA, %i[id name]))
    assert_equal('%-5<name>s', wf.format_string(TERSE_DATA, [:name]))
  end

  def test_to_s
    assert_equal("id1  name1\nid2  name2", wf.to_s)
    input = [{ id: 'id1', names: %w[Rob Robert], num: 67 },
             { id: 'id2', names: %w[Katharine Kate], num: 3 }]

    wf2 = WavefrontDisplayPrinter::Terse.new(input, %i[id names num])
    assert_equal("id1  Rob, Robert      67\nid2  Katharine, Kate  3",
                 wf2.to_s)

    wf3 = WavefrontDisplayPrinter::Terse.new(input, %i[id names])
    assert_equal("id1  Rob, Robert\nid2  Katharine, Kate", wf3.to_s)
  end

  def test_stringify
    assert_equal([{ id: 'id1', things: 'a, b, c', num: 5 },
                  { id: 'id2', things: 'letters', num: 3 }],
                 wf.stringify([{ id: 'id1', things: %w[a b c], num: 5 },
                               { id: 'id2', things: 'letters', num: 3 }],
                              [:things]))
  end

  def test_map_to_string
    assert_equal('key1=value1;key2=value2;key3=value3',
                 wf.map_to_string(key1: 'value1',
                                  key2: 'value2',
                                  key3: 'value3'))
  end

  def test_value_as_string
    assert_equal('a, b, c', wf.value_as_string(%w[a b c]))
    assert_equal('abc', wf.value_as_string('abc'))
  end

  def test_end_to_end_1
    input, expected = OutputTester.new.in_and_out('alerts-input.json',
                                                  'alerts-human-terse')
    out = WavefrontDisplayPrinter::Terse.new(input, %i[id status name]).to_s
    assert_equal(expected, "#{out}\n")
  end
end
