#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/savedsearch'

class SavedSearchEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Dump
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Search

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

  def friendly_name
    'saved search'
  end
end
