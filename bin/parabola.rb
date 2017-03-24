#!/usr/bin/env ruby
#
h, k, a = 25, 1000, 10

1.upto(49) do |x|
  $stdout.puts "#{Time.now.to_i} #{a * (x - h) ** 2 + k}"
  $stdout.flush
  sleep 1
end
