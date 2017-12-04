#!/usr/bin/env ruby

require_relative '../spec_helper'
require_relative '../../lib/wavefront-cli/string'
require_relative '../../lib/wavefront-cli/commands/base'

# Test extensions to string class
#
class StringTest < MiniTest::Test
  def test_cmd_fold
    str = "command subcommand #{CMN} [-a alpha] [-b beta] [-c gamma] <id>"
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

  def test_fold_options
    str = '-l, --longoption    a long option with a quite long ' \
          'description which needs folding'

    assert_equal(str.opt_fold,
                 '  -l, --longoption    a long option with a quite ' \
                 "long description which\n            needs folding\n")
    assert_equal(str.opt_fold(50),
                 "  -l, --longoption    a long option with a\n     " \
                 "       quite long description which needs\n      " \
                 "      folding\n")
    assert_equal(str.opt_fold(100), "  #{str}\n")
  end

  def test_to_seconds
    assert_equal(14, '14s'.to_seconds)
    assert_equal(300, '5m'.to_seconds)
    assert_equal(10_800, '3h'.to_seconds)
    assert_equal(1_209_600, '2w'.to_seconds)
    assert_raises(ArgumentError) { 'm'.to_seconds }
    assert_raises(ArgumentError) { '3m5s'.to_seconds }
  end
end
