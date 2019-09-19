# frozen_string_literal: true

require 'json'
require 'webmock/minitest'
require 'spy/integration'
require 'inifile'
require 'minitest'
require 'minitest/autorun'
require 'minitest/spec'
require 'pathname'
require_relative '../lib/wavefront-cli/controller'

unless defined?(CMD)
  ROOT = Pathname.new(__FILE__).dirname.parent
  CMD = 'wavefront'
  ENDPOINT = 'metrics.wavefront.com'
  TOKEN = '0123456789-ABCDEF'
  RES_DIR = Pathname.new(__FILE__).dirname + 'wavefront-cli' + 'resources'
  CF = RES_DIR + 'wavefront.conf'
  CF_VAL =  IniFile.load(CF)
  JSON_POST_HEADERS = {
    'Content-Type': 'application/json', Accept: 'application/json'
  }.freeze
  BAD_TAG = '*BAD_TAG*'
  TW = 80
  HOME_CONFIG = Pathname.new(ENV['HOME']) + '.wavefront'
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

  def status; end
end

CANNED_RESPONSE = DummyResponse.new

# Unit tests
#
class CliMethodTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = cliclass.new({})
  end

  def import_tester(word, have_fields, do_not_have_fields = [])
    input = wf.load_file(RES_DIR + 'imports' + "#{word}.json")
    x = wf.import_to_create(input)
    assert_instance_of(Hash, x)
    have_fields.each { |f| assert_includes(x.keys, f) }
    do_not_have_fields.each { |f| refute_includes(x.keys, f) }
  end
end

# stdlib extensions
#
class Hash
  # A quick way to deep-copy a hash.
  #
  def dup
    Marshal.load(Marshal.dump(self))
  end
end

require 'wavefront-sdk/core/response'
require_relative '../lib/wavefront-cli/base'

# For the given command word, loads up a canned API response and
# feeds it in to the appropriate display class, running the given
# method and returning standard out and standard error.
#
# @param word [String] command word, e.g. 'alert'
# @param method [Symbol] display method to run, e.g. :do_list
# @param klass [Class, Nil] CLI class. Worked out from the command
#   word in most cases, but must be overriden for two-word things.
# @return [Array] [stdout, stderr]
#
def command_output(word, method, klass = nil, infile = nil)
  infile ||= "#{word}-list.json"
  json = IO.read(RES_DIR + 'responses' + infile)
  resp = Wavefront::Response.new(json, 200)
  klass ||= Object.const_get(format('WavefrontCli::%<class_word>s',
                                    class_word: word.capitalize))
  klass = klass.new(format: :human)

  capture_io { klass.display(resp, method) }
end

def test_list_output(word, klass = nil)
  it 'tests terse output' do
    out, err = command_output(word, :do_list_brief, klass)
    refute_empty(out)
    assert_empty(err)
  end

  it 'tests long output' do
    out, err = command_output(word, :do_list_long, klass)
    refute_empty(out)
    assert_empty(err)
  end
end
