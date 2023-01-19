#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'spy'
require 'minitest/autorun'
require_relative '../../lib/wavefront-cli/event_store'

TEST_EVENT_STORE_DIR = Pathname.new(Dir.mktmpdir)

# Tests for event store class. This is tested well via the interface of the
# events CLI class.
#
class Test < MiniTest::Test
  attr_reader :wf

  include WavefrontCli::Constants

  def before_setup
    FileUtils.mkdir_p(TEST_EVENT_STORE_DIR)
  end

  def setup
    @wf = WavefrontCli::EventStore.new({}, TEST_EVENT_STORE_DIR)
  end

  def teardown
    FileUtils.rm_r(TEST_EVENT_STORE_DIR)
  end

  def test_state_file_needed?
    wf1 = WavefrontCli::EventStore.new({}, TEST_EVENT_STORE_DIR)
    assert wf1.state_file_needed?

    wf2 = WavefrontCli::EventStore.new({ nostate: true }, TEST_EVENT_STORE_DIR)
    refute wf2.state_file_needed?

    wf3 = WavefrontCli::EventStore.new({ instant: true }, TEST_EVENT_STORE_DIR)
    refute wf3.state_file_needed?

    wf4 = WavefrontCli::EventStore.new({ start: Time.now - 20, end: Time.now },
                                       TEST_EVENT_STORE_DIR)
    refute wf4.state_file_needed?
  end

  def test_event_file
    x = wf.event_file(id)
    assert_instance_of(Pathname, x)
    assert_equal(wf.dir, x.dirname)
    assert_equal(id, x.basename.to_s)

    assert_nil(wf.event_file('not_a_valid_id'))
  end

  def test_create_dir_ok
    dir = TEST_EVENT_STORE_DIR.join('testdir')
    refute dir.exist?
    wf.create_dir(dir)
    assert dir.exist?
    dir.unlink
  end

  def test_list
    setup_test_state_dir

    x = wf.list
    assert(x.all?(Pathname))
    assert_equal(4, x.size)
    empty_test_state_dir
  end

  def test_list_empty_stack
    wf = WavefrontCli::EventStore.new({}, TEST_EVENT_STORE_DIR)
    out, err = capture_io { assert_raises(SystemExit) { wf.list } }
    assert_empty(out)
    assert_equal("No locally recorded events.\n", err)
  end

  def test_pop_event
    setup_test_state_dir

    assert wf.dir.join('1568133440530:ev3:0').exist?
    assert_equal('1568133440530:ev3:0', wf.pop_event!)
    refute wf.dir.join('1568133440530:ev3:0').exist?

    empty_test_state_dir
  end

  def test_pop_event_named
    setup_test_state_dir

    assert wf.dir.join('1568133440515:ev1:1').exist?
    assert_equal('1568133440515:ev1:1', wf.pop_event!('ev1'))
    refute wf.dir.join('1568133440515:ev1:1').exist?

    empty_test_state_dir
  end

  def test_event_specific
    setup_test_state_dir

    assert wf.dir.join('1568133440515:ev1:1').exist?
    assert_equal('1568133440515:ev1:1', wf.event('1568133440515:ev1:1'))
    assert wf.dir.join('1568133440515:ev1:1').exist?

    empty_test_state_dir
  end

  def test_pop_event_empty_stack
    wf = WavefrontCli::EventStore.new({}, TEST_EVENT_STORE_DIR)
    out, err = capture_io { assert_raises(SystemExit) { wf.pop_event! } }
    assert_empty(out)
    assert_equal("No locally recorded events.\n", err)
  end

  def test_event_state_dir
    ENV['WF_EVENT_STATE_DIR'] = nil
    assert_equal(EVENT_STATE_DIR, wf.event_state_dir)

    ENV['WF_EVENT_STATE_DIR'] = '/tmp/tester'
    assert_equal(Pathname.new('/tmp/tester'), wf.event_state_dir)
    ENV['WF_EVENT_STATE_DIR'] = nil

    assert_equal(Pathname.new('/tmp/mydir'), wf.event_state_dir('/tmp/mydir'))
  end

  def test_create_dir_fail
    spy = Spy.on(FileUtils, :mkdir_p).and_return(false)

    assert_raises(WavefrontCli::Exception::SystemError) do
      wf.create_dir(Pathname.new('/any/old/directory'))
    end

    assert spy.has_been_called?
    spy.unhook
  end

  def test_event_file_data
    wf = WavefrontCli::EventStore.new({ desc: 'test event' },
                                      TEST_EVENT_STORE_DIR)
    x = wf.event_file_data
    assert_instance_of(String, x)
    y = JSON.parse(x, symbolize_names: true)
    assert_equal('test event', y[:description])
    assert_equal(%i[hosts description severity tags], y.keys)
    assert_nil(y[:tags])
  end

  def test_create
    refute (wf.dir + id).exist?
    out, err = capture_io { wf.create!(id) }
    assert_match(/Event state recorded at .*#{id}./, out)
    assert_empty(err)
    event_file = wf.dir + id
    assert event_file.exist?
    event_file.unlink
    refute event_file.exist?
  end

  def test_create_with_nostate
    wf1 = WavefrontCli::EventStore.new(nostate: true)
    assert_nil wf1.create!(id)
  end

  private

  def id
    '1481553823153:testevstore:0'
  end

  def dummy_event_files
    %w[1568133440510:ev1:0
       1568133440515:ev1:1
       1568133440520:ev2:0
       1568133440530:ev3:0]
  end

  def setup_test_state_dir
    dummy_event_files.each do |f|
      File.open(wf.dir + f, 'w') { |fh| fh.puts('dummy_data') }
    end
  end

  def empty_test_state_dir
    dummy_event_files.each do |f|
      file = wf.dir + f
      FileUtils.rm(file) if file.exist?
    end
  end
end
