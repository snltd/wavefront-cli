#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/source'

class SourceEndToEndTest < EndToEndTest
  #include WavefrontCliTest::Describe
  #include WavefrontCliTest::Search
  #include WavefrontCliTest::Tag

  def test_list
    assert_cmd_gets('list', '/api/v2/source')

    assert_noop('list',
        'uri: GET https://default.wavefront.com/api/v2/source')
    assert_abort_on_missing_creds('list')
  end

  def test_description_set
  end

  def test_description_clear
  end

  def test_clear
  end

  private

  def id
    '74a247a9-f67c-43ad-911f-fabafa9dc2f3joyent'
  end

  def invalid_id
    '(>_<)'
  end

  def cmd_word
    'source'
  end
end
