# frozen_string_literal: true

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
    before_setup if respond_to?(:before_setup)
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

  def wall_time
    half_an_hour_ago = TEE_ZERO - (30 * 60)
    start_time = Time.at(half_an_hour_ago.to_i - half_an_hour_ago.sec)
    [start_time, Time.at(start_time + (10 * 60))]
  end

  def epoch_time
    wall_time.map { |t| parse_time(t, true) }
  end

  def start_and_end_opts
    format('-s %<start_time>s -e %<end_time>s',
           start_time: wall_time[0].strftime('%H:%M'),
           end_time: wall_time[1].strftime('%H:%M'))
  end

  # Set this to true for things that use cursors rather than offsets
  #
  def cannot_handle_offsets
    false
  end

  def dummy_response
    { status: { result: 'OK', message: '', code: 200 },
      items: [] }.to_json
  end
end
