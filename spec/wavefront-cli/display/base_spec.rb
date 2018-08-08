#!/usr/bin/env ruby

require 'date'
require 'map'
require 'pathname'
require_relative(File.join('../../../lib/wavefront-cli/display',
                           Pathname.new(__FILE__).basename
                           .to_s.sub('_spec.rb', '')))
require_relative 'spec_helper'

S_DATA = Map.new
S_OPTIONS = { '<id>': 'abc123' }.freeze

# Test base class for display methods
#
class WavefrontDisplayBaseTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontDisplay::Base.new(S_DATA, S_OPTIONS)
  end

  def test_put_id_first
    assert_equal(wf.put_id_first(k1: 1, k2: 2, id: 3, k4: 4),
                 id: 3, k1: 1, k2: 2, k4: 4)
    assert_equal(wf.put_id_first(id: 3, k1: 1, k2: 2, k4: 4),
                 id: 3, k1: 1, k2: 2, k4: 4)
    assert_equal(wf.put_id_first(k2: 1, k1: 2, k4: 4),
                 k2: 1, k1: 2, k4: 4)
  end

  def test_run; end

  def test_friendly_name
    assert_equal(wf.friendly_name, 'base')
  end

  def test_do_list
    out = Spy.on(wf, :long_output)
    wf.do_list
    assert out.has_been_called?
  end

  def test_do_list_brief
    out = Spy.on(wf, :multicolumn)
    wf.do_list_brief
    assert out.has_been_called?
  end

  def test_do_import
    out = Spy.on(wf, :long_output)
    assert_output("Imported base.\n") { wf.do_import }
    assert out.has_been_called?
  end

  def test_do_delete
    assert_output("Deleted base 'abc123'.\n") { wf.do_delete }
  end

  def test_do_undelete
    assert_output("Undeleted base 'abc123'.\n") { wf.do_undelete }
  end

  def test_do_tag_add
    assert_output("Tagged base 'abc123'.\n") { wf.do_tag_add }
  end

  def test_do_tag_delete
    assert_output("Deleted tag from base 'abc123'.\n") { wf.do_tag_delete }
  end

  def test_do_tag_clear
    assert_output("Cleared tags on base 'abc123'.\n") { wf.do_tag_clear }
  end

  def test_do_tag_set
    assert_output("Set tags on base 'abc123'.\n") { wf.do_tag_set }
  end

  def test_do_tags
    assert_output("No tags set on base 'abc123'.\n") { wf.do_tags }

    assert_output("tag1\ntag2\n") do
      WavefrontDisplay::Base.new(%w[tag1 tag2], S_OPTIONS).do_tags
    end

    assert_output("tag1\n") do
      WavefrontDisplay::Base.new(%w[tag1], S_OPTIONS).do_tags
    end
  end

  def test_drop_fields_1
    data = { k1: 'string', k2: Time.now.to_i, k3: Time.now.to_i }
    wf = WavefrontDisplay::Base.new(data)
    wf.drop_fields
    assert_equal(wf.instance_variable_get(:@data), data)
  end

  def test_drop_fields_2
    data = { k1: 'string', k2: Time.now.to_i, k3: Time.now.to_i }
    wf = WavefrontDisplay::Base.new(data)
    wf.drop_fields(:k1)
    assert_equal(wf.instance_variable_get(:@data),
                 k2: Time.now.to_i, k3: Time.now.to_i)
  end

  def test_drop_fields_3
    data = { k1: 'string', k2: Time.now.to_i, k3: Time.now.to_i }
    wf = WavefrontDisplay::Base.new(data)
    wf.drop_fields(:k1, :k3)
    assert_equal(wf.instance_variable_get(:@data), k2: Time.now.to_i)
  end

  def test_readable_time_1
    data = { k1: 'string', k2: Time.now.to_i, k3: Time.now.to_i }
    wf = WavefrontDisplay::Base.new(data)
    wf.readable_time
    assert_equal(wf.instance_variable_get(:@data), data)
  end

  def test_readable_time_2
    data = { k1: 'string', k2: 1_499_426_615, k3: 1_499_426_615 }
    wf = WavefrontDisplay::Base.new(data)
    wf.readable_time(:k2)
    x = wf.data
    assert x.is_a?(Hash)
    assert_equal(x.size, 3)
    assert_equal(x.keys, %i[k1 k2 k3])
    assert_equal(x[:k1], 'string')
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/, x[:k2])
    assert_equal(x[:k3], 1_499_426_615)
  end

  def test_readable_time_3
    data = { k1: 'string', k2: 1_499_426_615, k3: 1_499_426_615 }
    wf = WavefrontDisplay::Base.new(data)
    wf.readable_time(:k2, :k3)
    x = wf.data
    assert x.is_a?(Hash)
    assert_equal(x.size, 3)
    assert_equal(x.keys, %i[k1 k2 k3])
    assert_equal(x[:k1], 'string')
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/, x[:k2])
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/, x[:k3])
  end

  def test_human_time
    assert_raises(ArgumentError) { wf.human_time([1, 2, 3]) }
    assert_raises(ArgumentError) { wf.human_time(123) }
    assert_raises(ArgumentError) { wf.human_time(12_345_678_901_234) }
    assert_equal('2017-07-07 11:23:35', wf.human_time(1_499_426_615, true))
    # rubocop:disable Style/DateTime
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d.\d{3}$/,
                 wf.human_time(DateTime.now.strftime('%Q')))
    # rubocop:enable Style/DateTime
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/,
                 wf.human_time(Time.now.to_i))
    assert_equal('2017-07-07 11:23:35.123', wf.human_time(1_499_426_615_123,
                                                          true))
  end
end
