#!/usr/bin/env ruby

id = 'dev.cli.test'
bad_id = '(>_<)'
word = 'metric'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  missing_creds(word, ["describe #{id}"])
  cmd_to_call(word, "describe #{id}",
              path: "/api/v2/chart/#{word}/detail?m=#{id}")
  cmd_to_call(word, "describe -g ptn1 #{id}",
              path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1")
  cmd_to_call(word, "describe -g ptn1 -g ptn2 #{id}",
              path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1&h=ptn2")
  cmd_to_call(word, "describe -g ptn1 -g ptn2 -o 10 #{id}",
              path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1&h=ptn2&c=10")

  invalid_ids(word, ["describe #{bad_id}"])
end
