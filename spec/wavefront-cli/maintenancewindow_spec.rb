#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../support/command_base'
require_relative '../../lib/wavefront-cli/maintenancewindow'

# Ensure 'window' commands produce the correct API calls.
#
class MaintenanceWindowEndToEndTest < EndToEndTest
  include WavefrontCliTest::List
  include WavefrontCliTest::Describe
  include WavefrontCliTest::Dump
  include WavefrontCliTest::Delete
  # include WavefrontCliTest::Import
  include WavefrontCliTest::Set
  include WavefrontCliTest::Search

  def test_create
    quietly do
      assert_cmd_posts('create -d testing --host shark test_window',
                       '/api/v2/maintenancewindow',
                       endTimeInSeconds: a_timestamp,
                       reason: 'testing',
                       relevantHostNames: %w[shark],
                       startTimeInSeconds: a_timestamp,
                       title: 'test_window')
    end

    assert_abort_on_missing_creds('create -d testing -H box test_window')
    assert_usage('create test_window')
  end

  def test_create_with_boundaries
    quietly do
      assert_cmd_posts('create --desc testing -H shark -s 1566776337 ' \
                       '-H box -e 1566776399 test_window',
                       '/api/v2/maintenancewindow',
                       endTimeInSeconds: 1_566_776_399,
                       reason: 'testing',
                       relevantHostNames: %w[shark box],
                       startTimeInSeconds: 1_566_776_337,
                       title: 'test_window')
    end

    assert_noop(
      'create --desc testing -H shark -s 1566776337 -H box ' \
      '-e 1566776399 test_window',
      'uri: POST https://default.wavefront.com/api/v2/maintenancewindow',
      'body: ' + { title: 'test_window',
                   startTimeInSeconds: 1_566_776_337,
                   endTimeInSeconds: 1_566_776_399,
                   reason: 'testing',
                   relevantHostNames: %w[shark box] }.to_json
    )
  end

  def test_create_with_boundaries_and_tags
    quietly do
      assert_cmd_posts('create -d testing -A alert_tag_1 -A alert_tag_2 ' \
                       '--start 1566776337 --end 1566776399 test_window',
                       '/api/v2/maintenancewindow',
                       endTimeInSeconds: 1_566_776_399,
                       reason: 'testing',
                       relevantCustomerTags: %w[alert_tag_1 alert_tag_2],
                       startTimeInSeconds: 1_566_776_337,
                       title: 'test_window')
    end
  end

  def test_close
    quietly do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).with(body: { id: '1538845632142',
                       reason: 'CLI testing',
                       relevantCustomerTags: [],
                       relevantHostTags: ['physical'],
                       startTimeInSeconds: 1_538_812_800,
                       endTimeInSeconds: a_timestamp,
                       title: 'test_2' })
                   .to_return(body: dummy_response, status: 200)

        wf.new("window close #{id} #{p[:cmdline]}".split)

        assert_requested(get_stub)
        assert_requested(put_stub)
      end
    end

    assert_cannot_noop("close #{id}")
    assert_abort_on_missing_creds("close #{id}")
    assert_usage('close')
  end

  def test_extend_to
    quietly do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).with(body: { id: '1538845632142',
                       reason: 'CLI testing',
                       relevantCustomerTags: [],
                       relevantHostTags: ['physical'],
                       startTimeInSeconds: 1_538_812_800,
                       endTimeInSeconds: 1_566_781_528,
                       title: 'test_2' })
                   .to_return(body: dummy_response, status: 200)

        wf.new("window extend to 1566781528 #{id} #{p[:cmdline]}".split)

        assert_requested(get_stub)
        assert_requested(put_stub)
      end
    end

    assert_cannot_noop("extend to 2:00 #{id}")
    assert_usage("extend #{id} to 2:00")
    assert_usage('extend')
  end

  def test_extend_by
    quietly do
      all_permutations do |p|
        get_stub = stub_request(
          :get,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).to_return(body: canned_response.to_json, status: 200)

        put_stub = stub_request(
          :put,
          "https://#{p[:endpoint]}/api/v2/maintenancewindow/#{id}"
        ).with(body: { id: '1538845632142',
                       reason: 'CLI testing',
                       relevantCustomerTags: [],
                       relevantHostTags: ['physical'],
                       startTimeInSeconds: 1_538_812_800,
                       endTimeInSeconds: a_timestamp,
                       title: 'test_2' })
                   .to_return(body: dummy_response, status: 200)

        wf.new("window extend by 1h #{id} #{p[:cmdline]}".split)

        assert_requested(get_stub, times: 2)
        assert_requested(put_stub)
      end
    end

    assert_cannot_noop("extend by 1h #{id}")
    assert_usage("extend 1h #{id}")
    assert_usage("extend by an hour #{id}")
  end

  def test_ongoing
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('ongoing',
                         '/api/v2/search/maintenancewindow',
                         state_search('ongoing').to_json)
      end
    end

    assert_noop(
      'ongoing',
      'uri: POST https://default.wavefront.com/api/v2/search/maintenancewindow',
      'body: ' + { limit: 999,
                   offset: 0,
                   query: [{ key: 'runningState',
                             value: 'ongoing',
                             matchingMethod: 'EXACT' }],
                   sort: { field: 'runningState',
                           ascending: true } }.to_json
    )

    assert_empty(err)
    assert_equal('No maintenance windows currently ongoing.', out.strip)
    assert_abort_on_missing_creds('ongoing')
  end

  def test_pending
    out, err = capture_io do
      assert_raises(SystemExit) do
        assert_cmd_posts('pending',
                         '/api/v2/search/maintenancewindow',
                         state_search('pending').to_json)
      end
    end

    assert_noop(
      'pending',
      'uri: POST https://default.wavefront.com/api/v2/search/maintenancewindow',
      'body: ' + { limit: 999,
                   offset: 0,
                   query: [{ key: 'runningState',
                             value: 'pending',
                             matchingMethod: 'EXACT' }],
                   sort: { field: 'runningState',
                           ascending: true } }.to_json
    )

    assert_empty(err)
    assert_equal('No maintenance windows in the next 24 hours.', out.strip)
    assert_abort_on_missing_creds('pending')
  end

  private

  def id
    '1493324005091'
  end

  def invalid_id
    '__BAD__'
  end

  def cmd_word
    'window'
  end

  def api_path
    'maintenancewindow'
  end

  def sdk_class_name
    'MaintenanceWindow'
  end

  def friendly_name
    'maintenance window'
  end

  def set_key
    'title'
  end

  def import_fields
    %i[startTimeInSeconds endTimeInSeconds relevantCustomerTags
       title relevantHostTags]
  end

  def canned_response
    { id: '1538845632142',
      reason: 'CLI testing',
      customerId: 'sysdef',
      relevantCustomerTags: [],
      title: 'test_2',
      startTimeInSeconds: 1_538_812_800,
      endTimeInSeconds: 1_566_780_739,
      relevantHostTags: ['physical'],
      creatorId: 'rob@sysdef.xyz',
      updaterId: 'rob@sysdef.xyz',
      createdEpochMillis: 1_538_845_632_142,
      updatedEpochMillis: 1_566_780_740_722,
      eventName: 'Maintenance Window: test_2',
      runningState: 'ENDED',
      sortAttr: 1_000_000 }
  end

  def state_search(state)
    { limit: 999,
      offset: 0,
      query: [{ key: 'runningState',
                value: state,
                matchingMethod: 'EXACT' }],
      sort: { field: 'runningState', ascending: true } }
  end
end
