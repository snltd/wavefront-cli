#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../constants'
require_relative '../../../lib/wavefront-cli/stdlib/string'
require_relative '../../../lib/wavefront-cli/commands/base'

# Test extensions to string class
#
class StringTest < MiniTest::Test
  def test_cmd_fold
    cmn = '[-DnV] [-c file] [-P profile] [-E endpoint] [-t token]'
    str = "command subcommand #{cmn} [-a alpha] [-b beta] [-c gamma] <id>"
    assert_equal(str.cmd_fold,
                 'command subcommand [-DnV] [-c file] [-P profile] ' \
                 "[-E endpoint]\n          [-t token] [-a alpha] " \
                 '[-b beta] [-c gamma] <id>')
    assert_equal(str.cmd_fold(240), str)
    assert_equal(str.cmd_fold(50),
                 "command subcommand [-DnV] [-c file]\n          [-P " \
                 "profile] [-E endpoint] [-t token]\n          [-a " \
                 'alpha] [-b beta] [-c gamma] <id>')
  end

  def test_opt_fold
    assert_equal('short string'.opt_fold, '  short string')

    str = '-o, --option PARAMETER a rather pointless option with a ' \
          'needlessly wordy description string'
    pad = "\n#{' ' * 12}"
    assert_equal("  -o, --option PARAMETER a#{pad}rather pointless" \
                 "#{pad}option with a#{pad}needlessly wordy#{pad}" \
                 "description#{pad}string",
                 str.opt_fold(30, 10))
  end

  # rubocop:disable Layout/LineContinuationLeadingSpace
  def test_fold_options
    str = '-l, --longoption    a long option with a quite long ' \
          'description which needs folding'

    assert_equal(str.opt_fold,
                 '  -l, --longoption    a long option with a quite ' \
                 "long description which\n            needs folding")
    assert_equal(str.opt_fold(50),
                 "  -l, --longoption    a long option with a\n     " \
                 "       quite long description which needs\n      " \
                 '      folding')
    assert_equal(str.opt_fold(100), "  #{str}")
  end
  # rubocop:enable Layout/LineContinuationLeadingSpace

  def test_to_seconds
    assert_equal(14, '14s'.to_seconds)
    assert_equal(300, '5m'.to_seconds)
    assert_equal(10_800, '3h'.to_seconds)
    assert_equal(1_209_600, '2w'.to_seconds)
    assert_raises(ArgumentError) { 'm'.to_seconds }
    assert_raises(ArgumentError) { '3m5s'.to_seconds }
  end

  def test_unit_factor
    assert_equal(60, '1'.unit_factor(:m))
    assert_equal(1, '1'.unit_factor('m'))
    assert_equal(1, '1'.unit_factor(:t))
  end

  def test_to_snake
    assert_equal('snake_case', 'snakeCase'.to_snake)
    assert_equal('lots_and_lots_of_words', 'lotsAndLotsOfWords'.to_snake)
    assert_equal('unchanged', 'unchanged'.to_snake)
    assert_equal('Unchanged', 'Unchanged'.to_snake)
  end

  def test_value_fold
    input = 'A reasonably long string which might for instance be a ' \
            'descripton of an alert. Perhaps an embedded runbook.'

    expected = 'A reasonably long string which might for
                                      instance be a descripton of an alert.
                                      Perhaps an embedded runbook.'

    assert_equal(expected, input.value_fold(38))
  end
end
