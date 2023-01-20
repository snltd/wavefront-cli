#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'minitest/autorun'
require_relative '../../constants'
require_relative '../../../lib/wavefront-cli/commands/base'

# Abstract class for testing commands
#
class WavefrontCommmandBaseTest < MiniTest::Test
  attr_reader :wf, :col_width, :skip_cmd

  def setup
    @wf = WavefrontCommandBase.new
    @col_width = 19 # has to be manually set for each class
  end

  def word
    self.class.name[17..-5]
  end

  def test_global_options
    opts = wf.global_options
    assert_instance_of(Array, opts)

    opts.each do |o|
      assert_instance_of(String, o)
      assert_match(/^-\w, --\w+/, o)
      refute o.end_with?('.')
    end
  end

  def test_common_options
    opts = wf.common_options
    assert_instance_of(Array, opts)

    opts.each do |o|
      assert_instance_of(String, o)
      assert_match(/^-\w, --\w+/, o)
      refute o.end_with?('.')
    end
  end

  def test_tag_commands
    cmds = wf.tag_commands
    assert_instance_of(Array, cmds)

    cmds.each do |o|
      assert_instance_of(String, o)
      assert_match(/^tags* /, o)
    end
  end

  def test_word
    assert_equal(wf.word, word.downcase)
  end

  def test_sdk_class
    assert_equal(wf.sdk_class, word)
  end

  def test_sdk_file
    assert_equal(wf.sdk_file, word.downcase)
  end

  def test_commands
    assert wf.commands.start_with?("Usage:\n")
    assert wf.commands.match(/ --help$/)

    wf.commands(600).split("\n")[1..].each do |c|
      next if skip_cmd && c.match(skip_cmd)

      assert_match(/^  \w+/, c)
      assert_includes(c, CMN) unless /--help$/.match?(c)
    end
  end

  def test_options
    assert wf.options(600).start_with?("Global options:\n")
    assert_match(/\nOptions:/, wf.options)

    wf.options(600).split("\n")[1..].each do |o|
      next if o == 'Global options:' || o == 'Options:' || o.empty?

      assert_instance_of(String, o)
      assert_match(/^  -\w, --\w+/, o)
      refute o.end_with?('.')
    end

    assert_equal(1, wf.options.split("\n").count(&:empty?))
  end

  def test_opt_row
    assert_equal(wf.opt_row('-s, --short    short option', 10),
                 '  -s, --short    short option')
    assert_equal(wf.opt_row('-s, --short    short option', 8),
                 '  -s, --short  short option')
    assert_equal(wf.opt_row(
                   '-l, --longoption    a long option with a quite ' \
                   'long description which needs folding', 15
                 ),
                 '  -l, --longoption    a long option with a quite long ' \
                 "description which\n                      needs folding")
    assert_equal(wf.opt_row(
                   '-h, --hugeoption    an option with a very long, far ' \
                   'too verbose description which is going need folding ' \
                   'more than one time, let me tell you', 12
                 ),
                 '  -h, --hugeoption an option with a very long, far too ' \
                 "verbose description\n                   which is going " \
                 'need folding more than one time, let me tell' \
                 "\n                   you")
  end

  def test_option_column_width
    assert_equal(col_width, wf.option_column_width)
  end

  def test_postscript
    assert_instance_of(String, wf.postscript)
  end

  def test_docopt
    x = wf.docopt
    assert x.start_with?("Usage:\n")
    assert_match("\nGlobal options:\n", x)
    assert_match("--help\n", x)
    assert_instance_of(String, x)
  end
end
