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

  #def test_fold_two_column_one_fold
    #str = "a reasonably long string which must be folded just once"
#
    #assert_equal(str.fold(40), "a reasonably long string which" \
                 #"\n          must be folded just once")
#
    ##assert_equal("  key    a very long string whose very length\n" \
                 #"         means that the method is going to\n" \
                 #"         have to fold it twice",
#
                 #wf.mk_line('key', 'a very long string whose very length means that the method is going to have to fold it twice', 40))
#
#
  #end
end
