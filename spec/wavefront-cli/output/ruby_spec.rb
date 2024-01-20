#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'helpers'
require_relative '../../../lib/wavefront-cli/output/ruby'

# We can't really test this without `eval`-ing the output, and
# knowing how squeamish people are about eval(), even in as
# controlled an environment as this, I'm not going to bother. We
# only p() an objecty anyway.
#
class WavefrontOutputJsonTest < Minitest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Ruby.new(load_query_response)
  end

  def test__run
    out = wfo._run
    assert_instance_of(Hash, out)
  end
end
