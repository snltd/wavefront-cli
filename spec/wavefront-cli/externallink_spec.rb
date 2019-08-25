#!/usr/bin/env ruby

require_relative 'command_base'
require_relative '../../lib/wavefront-cli/externallink'

# Ensure 'link' commands produce the correct API calls.
#
class ExternalLinkEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::Delete
  include WavefrontCliTest::Search

  def test_create_without_options
    quietly do
      assert_cmd_posts('create myname mydescription mytemplate',
                       '/api/v2/extlink',
                       name:        'myname',
                       template:    'mytemplate',
                       description: 'mydescription')
    end
  end

  def test_create_with_regexes
    quietly do
      assert_cmd_posts('create -m metricregex -s sourceregex myname ' \
                       'mydescription mytemplate',
                       '/api/v2/extlink',
                       name:              'myname',
                       template:          'mytemplate',
                       description:       'mydescription',
                       metricFilterRegex: 'metricregex',
                       sourceFilterRegex: 'sourceregex')
    end
  end

  def test_create_with_keys_and_regexes
    quietly do
      assert_cmd_posts('create -p key1=reg1 -p key2=reg2 ' \
                       '-m metricregex myname mydescription mytemplate',
                       '/api/v2/extlink',
                       name:              'myname',
                       template:          'mytemplate',
                       description:       'mydescription',
                       metricFilterRegex: 'metricregex',
                       pointFilterRegex: {
                         key1: 'reg1',
                         key2: 'reg2'
                       })
    end
  end

  private

  def id
    'lq6rPlSg2CFMSrg6'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'link'
  end

  def api_class
    'extlink'
  end

  def sdk_class_name
    'ExternalLink'
  end

  def friendly_name
    'external link'
  end

  def import_fields
    %i[condition displayExpression resolveAfterMinutes minutes severity
       tags target name]
  end
end
