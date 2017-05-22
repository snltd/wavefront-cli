#!/usr/bin/env ruby
#
require_relative '../../lib/wavefront-cli'
require 'webmock/minitest'
require_relative '../spec_helper'
require 'spy/integration'
require 'minitest/spec'
require 'inifile'
require_relative '../../lib/wavefront-cli/alert'

ENDPOINT = 'metrics.wavefront.com'
ID = '1481553823153'.freeze
TOKEN = '0123456789-ABCDEF'
RES_DIR = Pathname.new(__FILE__).dirname + 'resources'
CF = RES_DIR + 'conf.yaml'
CF_VAL =  IniFile.load(CF)

class Hash

  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end

# Return an array of CLI permutations and the values to which they relate

def permutations
  [ ["-t #{TOKEN} -E #{ENDPOINT}", { t: TOKEN, e: ENDPOINT }],
    ["-c #{CF}", { t: CF_VAL['default']['token'],
                   e: CF_VAL['default']['endpoint'] }],
    ["-c #{CF} -P other", { t: CF_VAL['other']['token'],
                            e: CF_VAL['other']['endpoint'] }],
    ["-c #{CF} -P other -t #{TOKEN}", { t: TOKEN,
                                        e: CF_VAL['other']['endpoint'] }],
    ["-c #{CF} -E #{ENDPOINT}", { t: CF_VAL['default']['token'],
                                  e: ENDPOINT }]
  ]
end

# Match a command to the final API call it should produce, applying options in
# as many combinations as possible, and ensuring the requisite display methods
# are called.
#
# @param cmd [String] command line args to supply to the Wavefront
#  command
# @param call [Hash]
#
def cmd_to_call(args, call)
  headers = { 'Accept':          /.*/,
              'Accept-Encoding': /.*/,
              'Authorization':  'Bearer 0123456789-ABCDEF',
              'User-Agent':     "wavefront-sdk 0.0.0",
            }

  headers.merge!(call[:headers]) if call.key?(:headers)
  method = call[:method] || :get
  fmts = call[:formats] ? ['-f json', '-f yaml', '-f human', ''] : ['']

  permutations.each do |opts, vals|
    describe "with #{args}" do
      fmts.each do |fmt|
        cmd = "#{args} #{opts} #{fmt}"
        uri = 'https://' + vals[:e] + call[:path]
        h = headers.dup
        h[:'Authorization'] = "Bearer #{vals[:t]}"
        it "runs #{cmd} and makes the correct API call" do
          stub_request(method, uri).with(headers: h).
            to_return(body: {}.to_json, status: 200)
          d = Spy.on_instance_method(WavefrontCli::Alert, :display)
          WavefrontCommand.new(cmd.split)
          assert d.has_been_called?
          assert_requested(method, uri, headers: h)
          WebMock.reset!
        end
      end
    end
  end
end

# Run a command we expect to fail, returning stdout and stderr
#
def fail_command(cmd)
  capture_io do
    begin
      WavefrontCommand.new(cmd.split).run
    rescue SystemExit => e
      assert_equal(1, e.status)
    end
  end
end

# Without a token, you should get an error. If you don't supply an endpoint, it
# will default to 'metrics.wavefront.com'.
#
def missing_creds(cmd, subcmds)
  describe 'commands with missing credentials' do
    subcmds.each do |subcmd|
      it "'#{subcmd}' errors and tells the user to use a token" do
        out, err = fail_command("#{cmd} #{subcmd} -c /f")
        assert_match(/supply an API token/, err)
        assert_match(/config file '\/f' not found./, out)
      end
    end
  end
end

describe 'alert command' do
  #missing_creds('alert', ['list', "describe #{ID}", "snooze #{ID}",
   #"delete #{ID}", "undelete #{ID}", "history #{ID}"])

  #cmd_to_call('alert list', path: '/api/v2/alert?limit=100&offset=0')
  #cmd_to_call('alert list -L 50', path: '/api/v2/alert?limit=50&offset=0')
  #cmd_to_call('alert list -L 20 -o 8', path: '/api/v2/alert?limit=20&offset=8')
  #cmd_to_call('alert list -o 60', path: '/api/v2/alert?limit=100&offset=60')

  cmd_to_call("alert describe #{ID}", path: "/api/v2/alert/#{ID}")
  cmd_to_call("alert history #{ID}", path: "/api/v2/alert/#{ID}/history")
  cmd_to_call("alert history -v 7 #{ID}", path: "/api/v2/alert/#{ID}/history/7")
  cmd_to_call("alert delete #{ID}",
              { method: :delete, path: "/api/v2/alert/#{ID}" })
  cmd_to_call("alert undelete #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/undelete" })
  cmd_to_call("alert snooze #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/snooze" })
  #cmd_to_call("alert snooze -T 800 #{ID}",
              #{ method: :post, path: "/api/v2/alert/#{ID}/snooze?seconds=800" })
  cmd_to_call("alert unsnooze #{ID}",
              { method: :post, path: "/api/v2/alert/#{ID}/unsnooze" })
  cmd_to_call("alert tags #{ID}", { path: "/api/v2/alert/#{ID}/tag" })
  cmd_to_call("alert tag set #{ID} mytag",
              { method: :post, path: "/api/v2/alert/#{ID}/tag/mytag" })
  cmd_to_call("alert tag add #{ID} mytag",
              { method: :put, path: "/api/v2/alert/#{ID}/tag/mytag" })
  cmd_to_call("alert tag delete #{ID} mytag",
              { method: :delete, path: "/api/v2/alert/#{ID}/tag/mytag" })
  cmd_to_call("alert summary", { path: "/api/v2/alert/summary" })
end
