require 'minitest/autorun'
require_relative '../support/minitest_assertions'
require_relative '../test_mixins/general'
require_relative '../../lib/wavefront-cli/controller'

class EndToEndTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCliController
  end

  def api_class
    cmd_word
  end

  def sdk_class
    Object.const_get("WavefrontCli::#{sdk_class_name}")
  end

  def sdk_class_name
    api_class.capitalize
  end
end
