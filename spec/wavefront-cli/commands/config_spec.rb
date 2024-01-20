#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/commands',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'base_spec'

# Test config commands and options. These are different from
# everything else, so we crudely override some of the test methods.
#
class WavefrontCommmandConfigTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandConfig.new
    @col_width = 19
  end

  def test_options
    assert wf.options(600).start_with?("Global options:\n")
    assert_match(/Options:\n/, wf.options)

    wf.options(600).split("\n")[1..].each do |o|
      next if o == 'Global options:' || o == 'Options:' || o.empty?

      assert_instance_of(String, o)
      assert_match(/^  -\w, --\w+/, o)
      refute o.end_with?('.')
    end

    assert_equal(wf.options.split("\n").count(&:empty?), 1)
  end

  def test_commands
    assert wf.commands.start_with?("Usage:\n")
    assert wf.commands.match(/ --help$/)

    wf.commands(600).split("\n")[1..].each do |c|
      next if skip_cmd && c.match(skip_cmd)

      assert_match(/^  \w+/, c)
    end
  end

  def test_docopt
    x = wf.docopt
    assert x.start_with?("Usage:\n")
    assert_match("\nGlobal options:\n", x)
    assert_match("--help\n", x)
    assert_instance_of(String, x)
  end
end
