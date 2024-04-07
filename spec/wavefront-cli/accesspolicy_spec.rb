#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/accesspolicy'

# Ensure 'accesspolicy' commands produce the correct API calls.
#
class AccesspolicyEndToEndTest < EndToEndTest
  include WavefrontCliTest::Describe

  private

  def cmd_word
    'accesspolicy'
  end
end
