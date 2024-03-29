#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../support/output_tester'
require_relative '../../../../lib/wavefront-cli/display/printer/long'

# Test verbose printing stuff
#
class TestWavefrontDisplayPrinterLong < Minitest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplayPrinter::Long.new({})
  end

  def test_preened_data
    assert_equal([{ k1: 1 }], wf.preened_data([{ k1: 1, k2: 2 }], [:k1]))
    assert_equal([{ k1: 1, k2: 2 }], wf.preened_data([{ k1: 1, k2: 2 }]))
    assert_equal([{}], wf.preened_data([{ k1: 1, k2: 2 }], [:k3]))
    assert_equal([{ k1: 1, k2: 2 }], wf.preened_data([{ k1: 1, k2: 2 }],
                                                     %i[k1 k2]))
    assert_equal([{ k1: 1 }, { k1: 10 }],
                 wf.preened_data([{ k1: 1, k2: 2 }, { k1: 10, k2: 12 }],
                                 [:k1]))

    assert_equal([{ 'k1' => 1 }, { 'k1' => 10 }],
                 wf.preened_data([{ 'k1' => 1,  'k2' => 2 },
                                  { 'k1' => 10, 'k2' => 12 }],
                                 [:k1]))
  end

  def test_preened_value
    assert_equal('test', wf.preened_value('test'))
    assert_equal('test', wf.preened_value('<b>test</b>'))
    assert_equal('test test', wf.preened_value('<b>test</b> <i>test</i>'))
  end

  def test_smart_value
    wf1 = WavefrontDisplayPrinter::Long.new({}, nil, nil, none: false)
    assert_equal('value', wf.smart_value('value'))
    assert_equal('<none>', wf.smart_value(''))
    assert_equal('', wf1.smart_value(''))
  end

  def test_opts
    pr = WavefrontDisplayPrinter::Long.new({}, {})
    assert_equal(pr.default_opts, pr.opts)

    pr = WavefrontDisplayPrinter::Long.new({}, nil, nil,
                                           indent: 4, padding: 3)
    assert_equal({ indent: 4,
                   padding: 3,
                   separator: true,
                   sep_depth: 3,
                   none: true }, pr.opts)

    pr = WavefrontDisplayPrinter::Long.new({}, nil, nil, none: false)
    assert_equal({ indent: 2,
                   padding: 2,
                   separator: true,
                   sep_depth: 3,
                   none: false }, pr.opts)
  end

  def test_longest_key_col
    input = [['short', 'short', 0],
             ['loooooooooooong', 'long', 1],
             ['long-ish', 'longish', 0]]

    pr = WavefrontDisplayPrinter::Long.new({})
    assert_equal(19, pr.longest_key_col(input))

    pr = WavefrontDisplayPrinter::Long.new({}, nil, nil, indent: 4)
    assert_equal(21, pr.longest_key_col(input))

    pr = WavefrontDisplayPrinter::Long.new({}, nil, nil, padding: 5)
    assert_equal(22, pr.longest_key_col(input))
  end

  # rubocop:disable Layout/LineContinuationLeadingSpace
  def test_to_s
    assert_equal("today\n" \
                 "  weather   sunny\n" \
                 '  day       Tuesday',
                 WavefrontDisplayPrinter::Long.new(
                   today: { weather: 'sunny', day: :Tuesday }
                 ).to_s)

    assert_equal("key1   val1\n" \
                 'key2   val2',
                 WavefrontDisplayPrinter::Long.new(
                   key1: 'val1', key2: 'val2'
                 ).to_s)
  end
  # rubocop:enable Layout/LineContinuationLeadingSpace

  def test_end_to_end
    input, expected = OutputTester.new.in_and_out('user-input.json',
                                                  'user-human-long')
    output = WavefrontDisplayPrinter::Long.new(input).to_s
    assert_equal(expected, "#{output}\n")

    input, expected = OutputTester.new.in_and_out('user-input.json',
                                                  'user-human-long-no_sep')
    output = WavefrontDisplayPrinter::Long.new(input, nil, nil,
                                               separator: false).to_s
    assert_equal(expected, "#{output}\n")
  end

  def test_end_to_end_fold
    input, expected = OutputTester.new.in_and_out('alert-input.json',
                                                  'alert-human-long')
    output = WavefrontDisplayPrinter::Long.new(input).to_s
    assert_equal(expected, "#{output}\n")
  end
end
