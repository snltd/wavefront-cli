#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../../lib/wavefront-cli/write'

# Test base writer
#
class WavefrontCliWriteTest < MiniTest::Test
  attr_reader :wf

  def setup
    @wf = WavefrontCli::Write.new({})
  end

  def test_validate_opts
    assert WavefrontCli::Write.new(using: 'unix',
                                   socket: '/tmp/sock').validate_opts
    assert WavefrontCli::Write.new(proxy: 'wavefront').validate_opts
    assert_raises 'WavefrontCli::Exception::CredentialError' do
      WavefrontCli::Write.new.validate_opts
    end

    assert_raises 'WavefrontCli::Exception::CredentialError' do
      WavefrontCli::Write.new(using: 'unix').validate_opts
    end
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

    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mvd')
    end
    assert_equal("'v' and 'd' are mutually exclusive", e.message)

    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mtT')
    end
    assert_equal("format string must include 'v' or 'd'", e.message)

    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mxvT')
    end
    assert_equal('unsupported field in format string', e.message)

    e = assert_raises('WavefrontCli::Exception::UnparseableInput') do
      wf.valid_format?('mvvT')
    end
    assert_equal('repeated field in format string', e.message)

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
end
