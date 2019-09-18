#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tmpdir'
require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/event'
require 'wavefront-sdk/support/mixins'

TEST_EVENT_DIR = Pathname.new('/tmp/wf_event_test')

# Test the 'event' command behaves as it should. Unit tests for class methods
# come later.
#
class EventEndToEndTest < EndToEndTest
  attr_reader :test_state_dir
  include Wavefront::Mixins

  include WavefrontCliTest::Describe
  include WavefrontCliTest::Delete
  # Ones above work, ones below don't
  # include WavefrontCliTest::Search
  # include WavefrontCliTest::Set
  # include WavefrontCliTest::Tags

  def before_setup
    @test_state_dir = Pathname.new(Dir.mktmpdir)
    ENV['WF_EVENT_STATE_DIR'] = test_state_dir.to_s
  end

  def teardown
    FileUtils.rm_r(test_state_dir)
  end

  def cmd_instance
    cmd_class.new(event_state_dir: TEST_EVENT_DIR)
    puts cmd_class
  end

  def test_list_no_options
    str = '/api/v2/event\?' \
          'earliestStartTimeEpochMillis=\d{13}+&' \
          'latestStartTimeEpochMillis=\d{13}+&' \
          'limit=100'

    quietly { assert_cmd_gets('list', Regexp.new(str)) }
  end

  def test_list_start_and_end_time
    quietly do
      assert_cmd_gets("list #{start_and_end_opts}",
                      '/api/v2/event?earliestStartTimeEpochMillis=' \
                      "#{epoch_time[0]}&latestStartTimeEpochMillis=" \
                      "#{epoch_time[1]}&limit=100")
    end
  end

  def test_list_start_and_end_time_offset_and_cursor
    quietly do
      assert_cmd_gets("list #{start_and_end_opts} -o #{id} --limit 8",
                      '/api/v2/event' \
                      "?earliestStartTimeEpochMillis=#{epoch_time[0]}" \
                      "&latestStartTimeEpochMillis=#{epoch_time[1]}" \
                      "&cursor=#{id}" \
                      '&limit=8')
    end
  end

  def test_create
    mock_id = "#{start_time}:#{event_name}:1"
    state_file = state_dir + mock_id

    out, err = capture_io do
      assert_cmd_posts("create #{event_name}",
                       '/api/v2/event',
                       { name: event_name,
                         startTime: a_ms_timestamp,
                         annotations: {},
                         hosts: [],
                         tags: [] },
                       { name: event_name,
                         id: mock_id,
                         startTime: start_time,
                         tags: [] }.to_json)
    end

    assert_empty(err)
    assert_match(/^Event state recorded at #{state_file}\.\n/, out)
    assert state_file.exist?
    assert_equal(
      "{\"hosts\":[],\"description\":null,\"severity\":null,\"tags\":[]}\n",
      IO.read(state_file)
    )

    assert_abort_on_missing_creds("create #{event_name}")
  end

  def test_create_with_hosts
    mock_id = "#{start_time}:#{event_name}:1"
    state_file = state_dir + mock_id
    refute state_file.exist?

    out, err = capture_io do
      assert_cmd_posts('create -d reason -H host1 -H host2 -g ' \
                       "mytag #{event_name}",
                       '/api/v2/event',
                       { name: event_name,
                         startTime: a_ms_timestamp,
                         annotations: { details: 'reason' },
                         hosts: %w[host1 host2],
                         tags: %w[mytag] },
                       { name: event_name,
                         id: mock_id,
                         startTime: start_time,
                         hosts: %w[host1 host2],
                         tags: %w[mytag] }.to_json)
    end

    assert_empty(err)
    assert_match(/^Event state recorded at #{state_file}\.\n/, out)
    assert state_file.exist?
    assert_equal('{"hosts":["host1","host2"],"description":"reason",' \
                 "\"severity\":null,\"tags\":[\"mytag\"]}\n",
                 IO.read(state_file))
  end

  def test_create_instantaneous_with_start_time
    out, err = capture_io do
      assert_cmd_posts("create -i -s #{start_time} -g tag1 " \
                       "-g tag2 #{event_name}",
                       '/api/v2/event',
                       { name: event_name,
                         startTime: start_time,
                         endTime: start_time + 1,
                         annotations: {},
                         hosts: [],
                         tags: %w[tag1 tag2] },
                       { name: event_name,
                         annotations: {},
                         id: "#{start_time}:#{event_name}:1",
                         endTime: start_time + 1,
                         startTime: start_time,
                         tags: %w[tag1 tag2] }.to_json)
    end

    assert_empty(err)
    assert_match(/^id            1481553823153:test_event:1\n/, out)
    assert_match(/\nannotations   <none>\n/, out)
    assert_match(/\ntags          tag1\n              tag2\n/, out)
  end

  def test_close_named_event
    quietly do
      assert_cmd_posts('close 1568133440520:ev2:0',
                       '/api/v2/event/1568133440520:ev2:0/close')
    end

    assert_abort_on_missing_creds("close #{id}")
  end

  def test_close_with_no_local_events
    quietly { assert_cmd_posts("close #{id}", "/api/v2/event/#{id}/close") }
    assert_exits_with('No locally recorded events.', 'close')
  end

  def test_close_with_local_events_no_match
    setup_test_state_dir
    assert_exits_with("No locally stored event matches 'X'.", 'close X')
  end

  def test_close_with_local_events_pop
    setup_test_state_dir
    assert((state_dir + '1568133440530:ev3:0').exist?)

    quietly do
      assert_cmd_posts('close', '/api/v2/event/1568133440530:ev3:0/close')
    end

    refute((state_dir + '1568133440530:ev3:0').exist?)
    assert((state_dir + '1568133440520:ev2:0').exist?)

    quietly do
      assert_cmd_posts('close', '/api/v2/event/1568133440520:ev2:0/close')
    end

    refute((state_dir + '1568133440520:ev2:0').exist?)
  end

  def test_wrap
    mock_id = "#{start_time}:#{event_name}:1"
    state_file = state_dir + mock_id

    all_permutations do |p|
      open_stub = stub_request(
        :post,
        "https://#{p[:endpoint]}/api/v2/event"
      ).with(body: { name: event_name,
                     startTime: a_ms_timestamp,
                     annotations: { details: 'reason' },
                     hosts: [],
                     tags: %w[mytag] })
                  .to_return(body:
                     { name: event_name,
                       id: mock_id,
                       startTime: start_time,
                       hosts: [],
                       tags: %w[mytag] }.to_json,
                             status: 200)

      close_stub = stub_request(
        :post,
        "https://#{p[:endpoint]}/api/v2/event/#{mock_id}/close"
      )
                   .with(body: 'null')

      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new('event wrap -C date -d reason -g mytag ' \
                 "#{event_name} #{p[:cmdline]}".split)
        end
      end

      lines = out.split("\n")

      assert_equal("Event state recorded at #{state_file}.", lines[0])
      assert_equal('Command output follows, on STDERR:', lines[1])
      assert_match(/^-+$/, lines[2])
      assert_match(/^-+$/, lines[3])
      refute_empty(err)
      assert_requested(open_stub)
      assert_requested(close_stub)
    end
  end

  def test_show
    setup_test_state_dir

    out, err = capture_io do
      assert_raises(SystemExit) { wf.new("event show -c #{CF}".split) }
    end

    assert_empty(err)
    assert_equal("1568133440530:ev3:0\n1568133440520:ev2:0\n" \
                 "1568133440515:ev1:1\n1568133440510:ev1:0\n", out)
  end

  private

  def id
    '1481553823153:testev'
  end

  def event_name
    'test_event'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'event'
  end

  def start_time
    1_481_553_823_153
  end

  def import_fields
    %i[method title creatorId triggers template]
  end

  def state_dir
    test_state_dir + (Etc.getlogin || 'notty')
  end

  def setup_test_state_dir
    FileUtils.mkdir_p(state_dir)

    %w[1568133440510:ev1:0
       1568133440515:ev1:1
       1568133440520:ev2:0
       1568133440530:ev3:0].each do |f|
      File.open(state_dir + f, 'w') { |fh| fh.puts('dummy_data') }
    end
  end
end

# Unit tests for class methods
#
class EventMethodTests < Minitest::Test
  attr_reader :wf, :wfse

  def setup
    @wf = WavefrontCli::Event.new({})
    @wfse = WavefrontCli::Event.new(start: wall_time[0],
                                    end: wall_time[1],
                                    limit: 55,
                                    cursor: '1481553823153:testev')
  end

  def test_create_dir_ok
    base = Pathname.new(Dir.mktmpdir)
    dir = base + 'testdir'
    refute dir.exist?
    wf.create_dir(dir)
    assert dir.exist?
    dir.unlink
    base.unlink
  end

  def test_create_dir_fail
    spy = Spy.on(FileUtils, :mkdir_p).and_return(false)

    assert_raises(WavefrontCli::Exception::SystemError) do
      wf.create_dir(Pathname.new('/any/old/directory'))
    end

    assert spy.has_been_called?
    spy.unhook
  end

  def test_list_args_defaults
    x = wf.list_args
    assert_instance_of(Array, x)
    assert_equal(4, x.size)
    assert_in_delta(((Time.now - 600).to_i * 1000), x[0], 1000)
    assert_in_delta((Time.now.to_i * 1000), x[1], 1000)
    assert_equal(100, x[2])
    assert_nil(x[3])
  end

  def test_list_args_options
    x = wfse.list_args
    assert_instance_of(Array, x)
    assert_equal(4, x.size)
    assert_equal(epoch_ms_time[0], x[0])
    assert_equal(epoch_ms_time[1], x[1])
    assert_equal(55, x[2])
    assert_equal('1481553823153:testev', x[3])
  end

  def test_window_start
    assert_kind_of(Numeric, wf.window_start)
    assert_equal(epoch_ms_time[0], wfse.window_start)
  end

  def test_window_end
    assert_kind_of(Numeric, wf.window_end)
    assert_equal(epoch_ms_time[1], wfse.window_end)
  end

  private

  def wall_time
    [Time.at(1_568_112_000), Time.at(1_568_112_999)]
  end

  def epoch_ms_time
    wall_time.map { |t| (t.to_i * 1000) }
  end
end
