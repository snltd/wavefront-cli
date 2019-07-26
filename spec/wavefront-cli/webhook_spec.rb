#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/webhook'

class WebhookEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Import
  include WavefrontCliTest::List
  include WavefrontCliTest::Search
  include WavefrontCliTest::Set

  private

  def id
    '9095WaGklE8Gy3M1'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'webhook'
  end
end
