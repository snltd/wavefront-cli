#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/notificant'

class NotificantEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  # include WavefrontCliTest::Import
  include WavefrontCliTest::List
  include WavefrontCliTest::Search
  include WavefrontCliTest::Set

  def test_test
    assert_repeated_output("Testing notificant '#{id}'.") do
      assert_cmd_posts("test #{id}", "/api/v2/notificant/test/#{id}")
    end

    assert_noop("test #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "notificant/test/#{id}", 'body: null')
    assert_invalid_id("test #{invalid_id}")
    assert_usage('test')
    assert_abort_on_missing_creds("test #{id}")
  end

  private

  def id
    '9wltLtYXsP8Je2kI'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'notificant'
  end

  def set_key
    'title'
  end

  def import_fields
    %i[method title creatorId triggers template]
  end
end
