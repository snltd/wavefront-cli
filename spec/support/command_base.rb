require 'minitest/autorun'
require_relative '../support/minitest_assertions'
require_relative '../test_mixins/general'
require_relative '../../lib/wavefront-cli/controller'

# An abstract class which facilitates "end-to-end" testing of
# commands.
#
class EndToEndTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCliController
  end

  def api_class
    cmd_word
  end

  def cmd_class
    Object.const_get("WavefrontCli::#{sdk_class_name}")
  end

  def cmd_instance
    cmd_class.new({})
  end

  def sdk_class_name
    api_class.capitalize
  end

  # Fields which must not be in import objects
  #
  def blocked_import_fields
    %i[id]
  end

  # the key to use when testing the 'set' command. The value is
  # always 'new_value'
  #
  def set_key
    'name'
  end

  def friendly_name
    cmd_word
  end

  # Set this to true for things that use cursors rather than offsets
  #
  def cannot_handle_offsets
    false
  end

  def dummy_response
    { status: { result: 'OK', message: '', code: 200 },
      items: []
    }.to_json
  end
end
