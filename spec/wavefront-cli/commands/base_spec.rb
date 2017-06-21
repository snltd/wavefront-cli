#!/usr/bin/env ruby
CMD = 'test'

require 'pathname'
require_relative './spec_helper'


require_relative(File.join('../../../lib/wavefront-cli/commands',
  Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')))


class WavefrontCommmandBaseTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCommandBase.new
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
      assert_match(/^tags* .* <id>/, o)
    end
  end

  def test_word
    assert_equal(wf.word, 'base')
  end

  def test_sdk_class
    assert_equal(wf.sdk_class, 'Base')
  end

  def test_sdk_file
    assert_equal(wf.sdk_file, 'base')
  end

  def test_commands; end # test from subclass

  def test_options; end  # test from subclass

  def test_opt_row
    gt
  end

  def test_option_column_width
    assert_equal(wf.option_column_width, 18)
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
