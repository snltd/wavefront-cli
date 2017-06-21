#!/usr/bin/env ruby

require_relative './spec_helper'

class WavefrontCommmandAlertTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCommand::Alert.new
  end

  def test_description
    assert_instance_of(wf.description, String)
  end
end
