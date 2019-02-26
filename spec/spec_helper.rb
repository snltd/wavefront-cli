require 'json'
require 'webmock/minitest'
require 'spy/integration'
require 'inifile'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'pathname'
require_relative '../lib/wavefront-cli/controller'

def all_commands
  cmd_dir = ROOT + 'lib' + 'wavefront-cli' + 'commands'

  files = cmd_dir.children.select do |f|
    f.extname == '.rb' && f.basename.to_s != 'base.rb'
  end

  files.each.with_object([]) { |c, a| a.<< c.basename.to_s.chomp('.rb') }
end

unless defined?(CMD)
  ROOT = Pathname.new(__FILE__).dirname.parent
  CMD = 'wavefront'.freeze
  ENDPOINT = 'metrics.wavefront.com'.freeze
  TOKEN = '0123456789-ABCDEF'.freeze
  RES_DIR = Pathname.new(__FILE__).dirname + 'wavefront-cli' + 'resources'
  CF = RES_DIR + 'wavefront.conf'
  CF_VAL =  IniFile.load(CF)
  JSON_POST_HEADERS = {
    'Content-Type': 'application/json', Accept: 'application/json'
  }.freeze
  CMDS = all_commands.freeze
  BAD_TAG = '*BAD_TAG*'.freeze
  TW = 80
  HOME_CONFIG = Pathname.new(ENV['HOME']) + '.wavefront'
end

# Return an array of CLI permutations and the values to which they relate
#
def permutations
  [["-t #{TOKEN} -E #{ENDPOINT}", { t: TOKEN, e: ENDPOINT }],
   ["-c #{CF}", { t: CF_VAL['default']['token'],
                  e: CF_VAL['default']['endpoint'] }],
   ["-c #{CF} -P other", { t: CF_VAL['other']['token'],
                           e: CF_VAL['other']['endpoint'] }],
   ["-c #{CF} -P other -t #{TOKEN}", { t: TOKEN,
                                       e: CF_VAL['other']['endpoint'] }],
   ["-c #{CF} -E #{ENDPOINT}", { t: CF_VAL['default']['token'],
                                 e: ENDPOINT }]]
end

# Object returned by cmd_to_call. Has just enough methods to satisfy
# the SDK
#
class DummyResponse
  def more_items?
    false
  end

  def response
    Map.new(items: [])
  end

  def empty?
    false
  end
end

CANNED_RESPONSE = DummyResponse.new

# Match a command to the final API call it should produce, applying
# options in as many combinations as possible, and ensuring the
# requisite display methods are called.
#
# @param cmd [String] command line args to supply to the Wavefront
#  command
# @param call [Hash]
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
def cmd_to_call(word, args, call, sdk_class = nil)
  headers = { 'Accept':          /.*/,
              'Accept-Encoding': /.*/,
              'Authorization':  'Bearer 0123456789-ABCDEF',
              'User-Agent':     "wavefront-cli-#{WF_CLI_VERSION}" }

  sdk_class ||= Object.const_get("WavefrontCli::#{word.capitalize}")

  headers.merge!(call[:headers]) if call.key?(:headers)
  method = call[:method] || :get
  fmts = call[:formats] ? ['-f json', '-f yaml', '-f human', ''] : ['']

  permutations.each do |opts, vals|
    describe "with #{word} #{args}" do
      fmts.each do |fmt|
        cmd = "#{word} #{args} #{opts} #{fmt}"

        uri = if call[:regex]
                Regexp.new(call[:path])
              else
                'https://' + vals[:e] + call[:path]
              end

        h = headers.dup
        h[:Authorization] = "Bearer #{vals[:t]}"

        it "runs #{cmd} and makes the correct API call" do
          if call.key?(:body)
            stub_request(method, uri).with(headers: h, body: call[:body])
                                     .to_return(body: {}.to_json,
                                                status: 200)
          else
            stub_request(method, uri).with(headers: h)
                                     .to_return(body: {}.to_json,
                                                status: 200)
          end

          require "wavefront-sdk/#{sdk_class.name.split('::').last.downcase}"
          Spy.on_instance_method(
            Object.const_get('Wavefront::ApiCaller'), :respond
          ).and_return(CANNED_RESPONSE)

          d = Spy.on_instance_method(sdk_class, :display)
          WavefrontCliController.new(cmd.split)
          assert d.has_been_called?
          assert_requested(method, uri, headers: h)
          WebMock.reset!
        end
      end
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/AbcSize

# Test no-ops
#
# @param output [Array] [URI, params]
#
def cmd_noop(word, cmd, output, sdk_class = nil)
  cmd = [word] + cmd.split + ['--noop'] + ["-t #{TOKEN} -E #{ENDPOINT}"]

  exit_code = output == :impossible ? 1 : 0

  it "runs #{cmd.join(' ')} and gets output without an API call" do
    out, err = capture_io do
      sdk_class ||= Object.const_get("WavefrontCli::#{word.capitalize}")
      require "wavefront-sdk/#{sdk_class.name.split('::').last.downcase}"
      begin
        WavefrontCliController.new(cmd).run
      rescue SystemExit => e
        assert_equal(exit_code, e.status)
      end
    end

    if output == :impossible
      assert_equal('Multiple API call operations cannot be performed ' \
                   "as no-ops.\n", err)
      assert_empty(out)
    else
      out = out.split("\n")
      refute_empty(out)
      assert_equal("SDK INFO: uri: #{output.first}", out.first)
      if output.size > 1
        assert_equal("SDK INFO: params: #{output.last}", out.last)
      end
      assert_empty(err)
    end
  end
end

# Wrapper to standard noop tests
#
def noop_tests(cmd, id, nodelete = false, pth = nil, sdk_class = nil)
  pth ||= cmd
  cmd_noop(cmd, 'list',
           ["GET https://metrics.wavefront.com/api/v2/#{pth}",
            offset: 0, limit: 100], sdk_class)
  cmd_noop(cmd, "describe #{id}",
           ["GET https://metrics.wavefront.com/api/v2/#{pth}/#{id}"],
           sdk_class)

  if nodelete == :skip
  elsif nodelete
    cmd_noop(cmd, "delete #{id}", :impossible, sdk_class)
  else
    cmd_noop(cmd, "delete #{id}",
             ["DELETE https://metrics.wavefront.com/api/v2/#{pth}/#{id}"],
             sdk_class)
  end
end

# Run a command we expect to fail, returning stdout and stderr
#
def fail_command(cmd)
  capture_io do
    begin
      WavefrontCliController.new(cmd.split).run
    rescue SystemExit => e
      assert_equal(1, e.status)
    end
  end
end

def invalid_something(cmd, subcmds, thing)
  subcmds.each do |sc|
    it "fails '#{sc}' because of an invalid #{thing}" do
      _out, err = fail_command("#{cmd} #{sc}")
      assert_match(/^'.*' is not a valid #{thing}.\n$/, err)
    end
  end
end

def invalid_tags(cmd, subcmds)
  subcmds.each do |sc|
    it "fails '#{sc}' because of an invalid tag" do
      _out, err = fail_command("#{cmd} #{sc}")
      assert_equal(err, "Invalid input. '#{BAD_TAG}' is not a valid tag.\n")
    end
  end
end

def invalid_ids(cmd, subcmds)
  subcmds.each do |sc|
    it "fails '#{sc}' on invalid input" do
      _out, err = fail_command("#{cmd} #{sc}")
      assert_match(/^'.+' is not a valid \w/, err)
    end
  end
end

# Without a token, you should get an error. If you don't supply an
# endpoint, it will default to 'metrics.wavefront.com'. The
# behaviour is different now, depending on whether you have
# ~/.wavefront or not.
#
def missing_creds(cmd, subcmds)
  describe 'commands with missing credentials' do
    subcmds.each do |subcmd|
      it "'#{subcmd}' errors and tells the user to use a token" do
        out, err = fail_command("#{cmd} #{subcmd} -c /f")

        if HOME_CONFIG.exist?
          assert_equal("Credential error. Missing API token.\n", err)
          assert_match(%r{config file '/f' not found.}, out)
        else
          assert_match(/Please run 'wf config setup'/, out)
        end
      end
    end
  end
end

# Generic list tests, needed by most commands
#
def list_tests(cmd, pth = nil, klass = nil)
  pth ||= cmd
  cmd_to_call(cmd, 'list', { path: "/api/v2/#{pth}?limit=100&offset=0" },
              klass)
  cmd_to_call(cmd, 'list -L 50',
              { path: "/api/v2/#{pth}?limit=50&offset=0" },
              klass)
  cmd_to_call(cmd, 'list -L 20 -o 8',
              { path: "/api/v2/#{pth}?limit=20&offset=8" }, klass)
  cmd_to_call(cmd, 'list -o 60',
              { path: "/api/v2/#{pth}?limit=100&offset=60" },
              klass)
end

def tag_tests(cmd, id, bad_id, pth = nil, klass = nil)
  pth ||= cmd
  cmd_to_call(cmd, "tags #{id}", { path: "/api/v2/#{pth}/#{id}/tag" },
              klass)
  cmd_to_call(cmd, "tag set #{id} mytag",
              { method: :post,
                path:    "/api/v2/#{pth}/#{id}/tag",
                body:    %w[mytag].to_json,
                headers: JSON_POST_HEADERS }, klass)
  cmd_to_call(cmd, "tag set #{id} mytag1 mytag2",
              { method: :post,
                path: "/api/v2/#{pth}/#{id}/tag",
                body: %w[mytag1 mytag2].to_json,
                headers: JSON_POST_HEADERS }, klass)
  cmd_to_call(cmd, "tag add #{id} mytag",
              { method: :put, path: "/api/v2/#{pth}/#{id}/tag/mytag" },
              klass)
  cmd_to_call(cmd, "tag delete #{id} mytag",
              { method: :delete, path: "/api/v2/#{pth}/#{id}/tag/mytag" },
              klass)
  cmd_to_call(cmd, "tag clear #{id}", { method:  :post,
                                        path:    "/api/v2/#{pth}/#{id}/tag",
                                        body:    [].to_json,
                                        headers: JSON_POST_HEADERS }, klass)
  invalid_ids(cmd, ["tags #{bad_id}",
                    "tag clear #{bad_id}",
                    "tag add #{bad_id} mytag",
                    "tag delete #{bad_id} mytag"])
  invalid_tags(cmd, ["tag add #{id} #{BAD_TAG}",
                     "tag delete #{id} #{BAD_TAG}"])
end

# Load in a canned query response
#
def load_query_response
  JSON.parse(IO.read(RES_DIR + 'sample_query_response.json'),
             symbolize_names: true)
end

def load_raw_query_response
  JSON.parse(IO.read(RES_DIR + 'sample_raw_query_response.json'),
             symbolize_names: true)
end

# We keep a bunch of Wavefront API responses as text files alongside
# canned responses in various formats. This class groups helpers for
# doing that.
#
class OutputTester
  # @param file [String] filename to load
  # @param only_items [Bool] true for the items hash, false for the
  #   whole loadedobject
  # @return [Object] canned raw responses used to test outputs
  #
  def load_input(file, only_items = true)
    ret = JSON.parse(IO.read(RES_DIR + 'display' + file),
                     symbolize_names: true)
    only_items ? ret[:items] : ret
  end

  # @param file [String] file to load
  # @return [String]
  #
  def load_expected(file)
    IO.read(RES_DIR + 'display' + file)
  end

  def in_and_out(input, expected, only_items = true)
    [load_input(input, only_items), load_expected(expected)]
  end
end

OUTPUT_TESTER = OutputTester.new

# stdlib extensions
#
class Hash
  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end
