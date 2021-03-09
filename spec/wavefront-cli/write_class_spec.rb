#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/wavefront-cli/controller'
require_relative '../../lib/wavefront-cli/write'

# Test base writer
#
class WavefrontCliWriteTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Write.new({})
  end

  def test_validate_opts_proxy
    assert wf.klass.new({ proxy: 'wavefront' }, writer: :proxy)

    x = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ socket: '/tmp/sock' }, writer: :proxy)
    end

    assert_equal('credentials must contain proxy address', x.message)
  end

  def test_validate_opts_api
    assert wf.klass.new({ endpoint: 'metrics.wavefront.com',
                          token: 'ABCDE-12345' }, writer: :api)

    x1 = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ endpoint: 'metrics.wavefront.com' }, writer: :api)
    end

    assert_equal('credentials must contain API token', x1.message)

    x2 = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ proxy: 'wavefront' }, writer: :api)
    end

    assert_equal('credentials must contain API endpoint', x2.message)

    x3 = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ token: 'ABCDE-12345' }, writer: :api)
    end

    assert_equal('credentials must contain API endpoint', x3.message)
  end

  def test_validate_opts_http
    assert wf.klass.new({ proxy: 'wavefront.localnet' }, writer: :http)

    x = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ endpoint: 'wavefront.localnet' }, writer: :http)
    end

    assert_equal('credentials must contain proxy address', x.message)
  end

  def test_validate_opts_socket
    assert wf.klass.new({ socket: '/tmp/sock' }, writer: :socket)

    x = assert_raises 'WavefrontCli::Exception::CredentialError' do
      wf.klass.new({ proxy: 'wavefront.localnet' }, writer: :socket)
    end

    assert_equal('credentials must contain socket file path', x.message)
  end

  def test_validate_opts_file
    assert WavefrontCli::Write.new(
      proxy: 'wavefront', metric: 'metric.path'
    ).validate_opts_file

    assert WavefrontCli::Write.new(
      proxy: 'wavefront', infileformat: 'fmv'
    ).validate_opts_file

    assert_raises 'WavefrontCli::Exception::InsufficientData' do
      WavefrontCli::Write.new(proxy: 'wavefront').validate_opts_file
    end

    assert_raises 'WavefrontCli::Exception::InsufficientData' do
      WavefrontCli::Write.new(
        proxy: 'wavefront', infileformat: 'fv'
      ).validate_opts_file
    end
  end

  def test_process_line
    assert wf.process_line('')

    wf1 = WavefrontCli::Write.new(tag: ['t1=v1'])
    wf1.setup_fmt('mv')

    assert_equal({ path: 'my.path', tags: { t1: 'v1' }, value: 1.23 },
                 wf1.process_line('my.path 1.23'))

    assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf1.process_line('10')
    end

    assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf1.process_line('my.path 10 t2=v2')
    end

    wf2 = WavefrontCli::Write.new({})
    wf2.setup_fmt('tmvT')

    assert_equal({ path: 'my.path',
                   value: 1.23,
                   ts: 1_553_269_739,
                   tags: { k1: 'value 1' } },
                 wf2.process_line('1553269739 my.path 1.23 k1="value 1"'))
  end

  def test_extract_tags
    assert_equal({ k1: 'v1' },
                 wf.extract_tags(['path', '10', 'k1=v1']))

    assert_equal({ k1: 'v1', k2: 'v2' },
                 wf.extract_tags(['path', '10', 'k1=v1 k2=v2']))

    assert_equal({ k1: 'val 1', k2: 'val 2' },
                 wf.extract_tags(['path', '10', 'k1="val 1" k2="val 2"']))

    assert_equal({}, wf.extract_tags(%w[path 10]))
  end

  def test_tags_to_hash
    assert_nil wf.tags_to_hash(nil)
    assert_equal({ k1: 'v1', k2: 'v2' }, wf.tags_to_hash(%w[k1=v1 k2=v2]))
    assert_equal({ k1: 'v1', k2: 'v2' }, wf.tags_to_hash(%w[k1=v1 junk k2=v2]))
    assert_equal({ 'key 1': 'value 1', k2: 'v2' },
                 wf.tags_to_hash(['"key 1"="value 1"', 'k2=v2']))
    assert_equal({ 'key 1': 'value 1', k2: 'v2' },
                 wf.tags_to_hash(["'key 1'='value 1'", 'k2=v2']))
    assert_equal({ k1: 'v1', k2: '' }, wf.tags_to_hash(%w[k1=v1 k2=]))
    assert_equal({ k1: 'v1', k2: 'v2' }, wf.tags_to_hash([%w[k1=v1 k2=v2]]))
  end

  def test_valid_format?
    %w[v mv vm tmv mtv mvT msvT tmvT].each do |str|
      assert wf.valid_format?(str)
    end
  end

  def test_invalid_format_v_and_d
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mvd')
    end

    assert_equal("'v' and 'd' are mutually exclusive", e.message)
  end

  def test_invalid_format_no_v_or_d
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mtT')
    end

    assert_equal("format string must include 'v' or 'd'", e.message)
  end

  def test_invalid_format_invalid_char
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mxvT')
    end

    assert_equal('unsupported field in format string', e.message)
  end

  def test_invalid_format_repeated_char
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mvvT')
    end

    assert_equal('repeated field in format string', e.message)
  end

  def test_invalid_format_duplicated_char
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('vmvTv')
    end

    assert_equal('repeated field in format string', e.message)
  end

  def test_invalid_format_big_t_in_middle
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mTv')
    end

    assert_equal("if used, 'T' must come at end of format string",
                 e.message)
  end

  def test_enough_fields?
    wf1 = WavefrontCli::Write.new({})
    wf1.setup_fmt('mv')

    assert wf1.enough_fields?('metric 100')
    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf1.enough_fields?('100')
    end
    assert_equal('Expected 2 fields, got 1', e.message)

    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf1.enough_fields?('metric 100 key="my value"')
    end
    assert_equal('Expected 2 fields, got 3', e.message)
  end

  def test_valid_timestamp?
    assert wf.valid_timestamp?(Time.now.to_i)
    refute wf.valid_timestamp?(Time.new(1999, 11, 30).to_i)
    refute wf.valid_timestamp?(Time.now.to_i + 367 * 24 * 60 * 60)
  end

  def test__sdk_class_and_default_port
    assert_equal('Wavefront::Write', wf._sdk_class)
    assert_equal(2878, wf.default_port)
    wf1 = WavefrontCli::Write.new(infileformat: 'mdT')
    assert_equal('Wavefront::Distribution', wf1._sdk_class)
    assert_equal(40_000, wf1.default_port)
    wf2 = WavefrontCli::Write.new(distribution: true)
    assert_equal('Wavefront::Distribution', wf2._sdk_class)
    assert_equal(40_000, wf2.default_port)
  end

  def test_process_input_file
    wf1 = WavefrontCli::Write.new({})
    wf1.setup_fmt('mv')
    d1 = ['my.path 1', 'my.path 2', 'my.path 3']
    assert_equal([{ path: 'my.path', value: 1.0 },
                  { path: 'my.path', value: 2.0 },
                  { path: 'my.path', value: 3.0 }],
                 wf1.process_input_file(d1))
  end

  def test_expand_dist
    assert_equal(wf.expand_dist([1, 1, 1]), [1, 1, 1])
    assert_equal(wf.expand_dist(['3x1']), [1, 1, 1])
    assert_equal(wf.expand_dist(%w[3x1 1x4]), [1, 1, 1, 4])
    assert_equal(wf.expand_dist([1, 1, 1, '2x2']).sort, [2, 2, 1, 1, 1].sort)
  end

  def test_distribution?
    assert WavefrontCli::Write.new(distribution: true).distribution?
    assert WavefrontCli::Write.new(infileformat: 'fmd').distribution?
    refute WavefrontCli::Write.new(infileformat: 'fma').distribution?
    refute WavefrontCli::Write.new({}).distribution?
  end

  def test_sane_value
    assert_equal(0, wf.sane_value(0))
    assert_equal(0, wf.sane_value(''))
    assert_equal(-10, wf.sane_value('-10.0'))
    assert_equal(10, wf.sane_value('   10'))
    assert_equal(10, wf.sane_value('\\10'))
    assert_equal(10, wf.sane_value('\10'))
    assert_raises(WavefrontCli::Exception::InvalidValue) { wf.sane_value(nil) }
    assert_raises(WavefrontCli::Exception::InvalidValue) { wf.sane_value({}) }
    assert_raises(WavefrontCli::Exception::InvalidValue) { wf.sane_value([]) }
  end

  def test_random_value_asymmetric_range
    lower_bound = -5
    upper_bound = 20

    max = (1..1000).map { wf.random_value(lower_bound, upper_bound) }.max
    min = (1..1000).map { wf.random_value(lower_bound, upper_bound) }.min

    assert(max <= upper_bound)
    assert(min >= lower_bound)
    refute_equal(max, min)
  end

  def test_random_value_symmetric_range
    lower_bound = -15
    upper_bound = 15

    max = (1..1000).map { wf.random_value(lower_bound, upper_bound) }.max
    min = (1..1000).map { wf.random_value(lower_bound, upper_bound) }.min

    assert(max <= upper_bound)
    assert(min >= lower_bound)
    refute_equal(max, min)
  end

  def test_random_value_single_value
    lower_bound = 5
    upper_bound = 5

    assert_equal([5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
                 (1..10).map { wf.random_value(lower_bound, upper_bound) })
  end
end
