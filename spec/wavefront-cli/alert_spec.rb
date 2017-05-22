#!/usr/bin/env ruby
#
require_relative '../../lib/wavefront-cli'
require 'webmock/minitest'
require_relative '../spec_helper'

ENDPOINT = 'https://metrics.wavefront.com'
ALERT = '1481553823153'.freeze

# Match a command to the final API call it should produce
#
# @param cmd [String] command line args to supply to the Wavefront
#  command
# @param call [Hash]
#
def cmd_to_call(args, call)
  puts "running wavefront #{args}"
  uri = ENDPOINT + call[:path]

  headers = { 'Accept':          /.*/,
              'Accept-Encoding': /.*/,
              'Authorization':  'Bearer 0123456789-ABCDEF',
              'User-Agent':     "wavefront-sdk 0.0.0",
            }

  headers.merge!(call[:headers]) if call.key?(:headers)

  puts "stubbing #{uri}"
  stub_request(call[:method], uri).with(headers: headers)
  WavefrontCommand.new(args.split)
end

class WavefrontCliAlertTest < MiniTest::Test

  def test_no_config
    ['list', "describe #{ALERT}", "snooze #{ALERT}", "delete #{ALERT}",
     "undelete #{ALERT}", "history #{ALERT}"].each do |cmd|

      out, err = capture_io do
        begin
          WavefrontCommand.new(cmd.split)
        rescue SystemExit => e
          assert_equal(1, e.status)
        end
      end

      assert_equal(
        "config file '/f' not found. Taking options from command-line.\n",
        out)
    end
  end

=begin
   def test_alert_list
    cmd_to_call('alert -t 0123456789-ABCDEF list', {
      method: :get,
      path:   '/api/v2/alert?limit=100&offset=10',
    })
  end
=end
end
