#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/notificant'

class NotificantEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Import
  include WavefrontCliTest::List
  include WavefrontCliTest::Search
  include WavefrontCliTest::Set

  def test_test
    assert_cmd_posts("test #{id}",
                     "/api/v2/notificant/test/#{id}", nil)
    assert_invalid_id("test #{invalid_id}")
    assert_usage('test')
    assert_abort_on_missing_creds("test #{id}")

    assert_noop("test #{id}",
                'uri: POST https://default.wavefront.com/api/v2/' \
                "notificant/test/#{id}", 'body: null')
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
end

class TestNotificantMethods < CliMethodTest
  def test_import_method
    import_tester(:notificant,
                  %i[method title creatorId triggers template],
                  %i[id])
  end

  def cliclass
    WavefrontCli::Notificant
  end
end
