#!/usr/bin/env ruby

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/event'

TEST_EVENT_DIR = Pathname.new('/tmp/wf_event_test')

# Test the event command behaves as it should
#
class EventEndToEndTest < EndToEndTest
  # include WavefrontCliTest::Describe
  # include WavefrontCliTest::Delete
  #
  # include WavefrontCliTest::Search
  # include WavefrontCliTest::Set

  def cmd_instance
    cmd_class.new(event_state_dir: TEST_EVENT_DIR)
  end

  def _test_list_no_options
    quietly do
      all_permutations do |p|
        stub = stub_request(:get, "https://#{p[:endpoint]}/api/v2/event")
               .with(query: hash_including(
                 limit: '100',
                 earliestStartTimeEpochMillis: /^\d{13}$/,
                 latestStartTimeEpochMillis: /^\d{13}$/ \
               ), headers: mk_headers(p[:token]))
               .to_return(body: DUMMY_RESPONSE, status: 200)

        wf.new("#{cmd_word} list #{p[:cmdline]}".split)
        assert_requested(stub)
      end
    end
  end

  def _test_list_offset_and_cursor
    quietly do
      all_permutations do |p|
        stub = stub_request(:get, "https://#{p[:endpoint]}/api/v2/event")
               .with(query: hash_including(
                 limit: '10',
                 cursor: id,
                 earliestStartTimeEpochMillis: /^\d{13}$/,
                 latestStartTimeEpochMillis: /^\d{13}$/ \
               ), headers: mk_headers(p[:token]))
               .to_return(body: DUMMY_RESPONSE, status: 200)

        wf.new("#{cmd_word} list -L 10 --cursor #{id} #{p[:cmdline]}".split)
        assert_requested(stub)
      end
    end
  end

  def _test_list_time_window
    start_time = '1564681681'
    end_time = '1564681900'

    quietly do
      all_permutations do |p|
        stub = stub_request(:get, "https://#{p[:endpoint]}/api/v2/event")
               .with(query: hash_including(
                 limit: '100',
                 earliestStartTimeEpochMillis: start_time,
                 latestStartTimeEpochMillis: end_time
               ), headers: mk_headers(p[:token]))
               .to_return(body: DUMMY_RESPONSE, status: 200)

        wf.new("#{cmd_word} list --start #{start_time} " \
               "--end #{end_time} #{p[:cmdline]}".split)
        assert_requested(stub)
      end
    end
  end

  def test_create
    start_time = 1_564_681_681

    assert_cmd_posts("create #{event_name} --start #{start_time}",
                     '/api/v2/event',
                     { name: event_name,
                       startTime: start_time,
                       annotations: {},
                       hosts: [],
                       tags: [] }.to_json)
  end

  def _test_close
    quietly { assert_cmd_posts("close #{id}", "/api/v2/event/#{id}/close") }
    assert_exits_with('No locally recorded events.', 'close')
    assert_abort_on_missing_creds("close #{id}")
  end

  def _test_dummy_events
    cmd_instance.state_dir = Pathname.new('/tmp')
    pp cmd_instance.state_dir
  end

  def _test_wrap; end

  #   def test_test
  #     assert_cmd_posts("test #{id}",
  #                      "/api/v2/notificant/test/#{id}", nil)
  #     assert_invalid_id("test #{invalid_id}")
  #     assert_usage('test')
  #     assert_abort_on_missing_creds("test #{id}")
  #
  #     assert_noop("test #{id}",
  #                 'uri: POST https://default.wavefront.com/api/v2/' \
  #                 "notificant/test/#{id}", 'body: null')
  #   end

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

  def import_fields
    %i[method title creatorId triggers template]
  end
end

# describe "#{word} command" do
#   missing_creds(word, ['list', "describe #{id}", "create #{id}",
#                        "close #{id}", "delete #{id}"])
#   cmd_to_call(word, "describe #{id}", path: "/api/v2/#{word}/#{id}")
#   cmd_to_call(word, "create -N #{id}",
#               method: :post, path: "/api/v2/#{word}")
#   cmd_to_call(word, "close #{id}",
#               method: :post, path: "/api/v2/#{word}/#{id}/close")
#   tag_tests(word, id, bad_id)
#   search_tests(word, id)
#   test_list_output(word)
# end
