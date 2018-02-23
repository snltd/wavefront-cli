#!/usr/bin/env ruby

word = 'query'

require_relative '../spec_helper'
require_relative "../../lib/wavefront-cli/#{word}"
require 'wavefront-sdk/mixins'
include Wavefront::Mixins

q = 'ts("dev.cli.test")'
t1 = parse_time('12:00', true)
t2 = parse_time('12:10', true)
o = '-g m -s 12:00'

describe "#{word} command" do
  missing_creds(word, ["-g m -s 12:00 '#{q}'", "raw #{q}"])

  cmd_to_call(word, "#{o} #{q}",
              path: '/api/v2/chart/api?g=m&i=false&listMode=true' \
                    "&q=ts(%22dev.cli.test%22)&s=#{t1}&sorted=true" \
                    '&strict=true&summarization=mean')
  cmd_to_call(word, "#{o} -e 12:10 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=m&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&strict=true&summarization=mean")

  cmd_to_call(word, "-g s -s 12:00 -e 12:10 -S max #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=s&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&strict=true&summarization=max")

  cmd_to_call(word, "-g s -s 12:00 -e 12:10 -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=s&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean&strict=true" \
                    '&p=100')

  cmd_to_call(word, "-iO -g h -s 12:00 -e 12:10 -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=h&i=true" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean" \
                    '&strict=true&p=100&includeObsoleteMetrics=true')

  cmd_to_call(word, "-N query -g h -s 12:00 -e 12:10 -p 100 #{q}",
              path: "/api/v2/chart/api?e=#{t2}&g=h&i=false" \
                    '&listMode=true&q=ts(%22dev.cli.test%22)' \
                    "&s=#{t1}&sorted=true&summarization=mean" \
                    '&strict=true&p=100&n=query')

  cmd_to_call(word, 'raw dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test')

  cmd_to_call(word, 'raw -H h1 dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1')

  cmd_to_call(word, 'raw -s 12:00 -H h1 dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{t1}")

  cmd_to_call(word, 'raw -s 12:00 -e 12:10 -H h1 dev.cli.test',
              path: '/api/v2/chart/raw?metric=dev.cli.test&source=h1' \
                    "&startTime=#{t1}&endTime=#{t2}")

end
