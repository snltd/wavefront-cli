#!/usr/bin/env ruby
#
require 'date'

q = 'ts("dev.cli.test")'
t1 = DateTime.strptime('12:00', '%H:%M').strftime("%Q")
t2 = DateTime.strptime('12:10', '%H:%M').strftime("%Q")
o = "-g m -s 12:00"
word = 'query'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"

describe "#{word} command" do
  #missing_creds(word, ["-g m -s 12:00 '#{q}'", "raw #{q}"])
  #cmd_to_call(word, "#{o} #{q}",
              #path: "/api/v2/chart/api?g=m&i=false&listMode=true&q=ts(%22dev.cli.test%22)&s=#{t1}&sorted=true&summarization=mean")
  cmd_to_call(word, "#{o} -e 12:10 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=m&i=false&listMode=true&q=ts(%22dev.cli.test%22)&s=#{t1}&sorted=true&summarization=mean")

  #
  #cmd_to_call(word, "describe -g ptn1 #{id}",
              #path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1")
  #cmd_to_call(word, "describe -g ptn1 -g ptn2 #{id}",
              #path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1&h=ptn2")
  #cmd_to_call(word, "describe -g ptn1 -g ptn2 -o 10 #{id}",
              #path: "/api/v2/chart/#{word}/detail?m=#{id}&h=ptn1&h=ptn2&c=10")
  #invalid_ids(word, ["describe #{bad_id}"])
end
