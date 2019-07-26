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

# Base for class unit tests
#
class CliMethodTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = cliclass.new({})
  end

  def import_tester(word, have_fields, do_not_have_fields = [])
    input = wf.load_file(RES_DIR + 'imports' + "#{word}.json")
    x = wf.import_to_create(input)
    assert_instance_of(Hash, x)
    have_fields.each { |f| assert_includes(x.keys, f) }
    do_not_have_fields.each { |f| refute_includes(x.keys, f) }
  end
end
