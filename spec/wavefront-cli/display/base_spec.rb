#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'map'
require 'minitest/autorun'
require 'spy/integration'
require_relative '../../../lib/wavefront-cli/display/base'

S_DATA = Map.new
S_OPTIONS = { '<id>': 'abc123' }.freeze

# Test base class for display methods
#
class WavefrontDisplayBaseTest < Minitest::Test
  attr_reader :wf, :wff

  def setup
    @wf = WavefrontDisplay::Base.new(S_DATA, S_OPTIONS)
    @wff = WavefrontDisplay::Base.new(S_DATA, S_OPTIONS.merge(fields: 'id'))
  end

  def test_prioritise_keys
    assert_equal({ a: 1, b: 2, c: 3, d: 4 },
                 wf.prioritize_keys({ b: 2, c: 3, a: 1, d: 4 }, %i[a b]))

    assert_equal({ id: 'my id', name: 'my name', numbers: [1, 2, 3] },
                 wf.prioritize_keys({ name: 'my name',
                                      numbers: [1, 2, 3],
                                      id: 'my id' }, %i[id name]))

    assert_equal({ name: 'my name', id: 'my id', numbers: [1, 2, 3] },
                 wf.prioritize_keys({ name: 'my name',
                                      numbers: [1, 2, 3],
                                      id: 'my id' }, %i[name id]))
    assert_equal([{ a: 1, b: 2, c: 3, d: 4 }, { a: 5, b: 6 }],
                 wf.prioritize_keys([{ b: 2, c: 3, a: 1, d: 4 },
                                     { b: 6, a: 5 }], %i[a b]))
  end

  def test_friendly_name
    assert_equal(wf.friendly_name, 'base')
  end

  def test_filter_data
    x = [{ a: 1, b: 2, c: 3 }, { a: 10, b: 11, c: 12 }]

    assert_equal([{ b: 2, a: 1 }, { b: 11, a: 10 }],
                 wf.filter_data(x, %i[b a]))

    assert_equal([{ b: 2, a: 1 }, { b: 11, a: 10 }],
                 wf.filter_data(x, %i[e b a f]))
  end

  def test_do_list
    out = Spy.on(wf, :long_output)
    wf.do_list
    assert out.has_been_called?
  end

  def test_do_list_brief
    out = Spy.on(wf, :multicolumn)
    wf.do_list_brief
    assert_equal(%i[id name], out.calls.first.args)
    assert out.has_been_called?
  end

  def test_do_list_fields
    out = Spy.on(wff, :multicolumn)
    wff.do_list_fields
    assert_equal(%i[id], out.calls.first.args)
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
    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d.\d{3}$/,
                 wf.human_time(DateTime.now.strftime('%Q')))

    assert_match(/^20\d\d-[01]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d$/,
                 wf.human_time(Time.now.to_i))
    assert_equal('2017-07-07 11:23:35.123', wf.human_time(1_499_426_615_123,
                                                          true))
    assert_equal('FOREVER', wf.human_time(-1))
  end
end
