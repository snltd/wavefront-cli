#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/savedsearch'

class SavedSearchEndToEndTest < EndToEndTest
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Import
  include WavefrontCliTest::List
  include WavefrontCliTest::Search
  include WavefrontCliTest::Set

  private

  def id
    '4rUipOK3'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'savedsearch'
  end

  def sdk_class_name
    'SavedSearch'
  end
end
