#!/usr/bin/env ruby

require_relative '../../spec_helper'
require_relative '../../../lib/wavefront-cli/output/ruby'

class WavefrontOutputJsonTest < MiniTest::Test
  attr_reader :wfo

  def setup
    @wfo = WavefrontOutput::Ruby.new(load_query_response)
  end

  # We can't really test this without `eval`-ing the output, and
  # knowing how squeamish people are about eval(), even in as
  # controlled an environment as this, I'm not going to bother. We
  # only p() an objecty anyway.
  #
  def test__run
    out = wfo._run
    assert_instance_of(Hash, out)
  end
end
