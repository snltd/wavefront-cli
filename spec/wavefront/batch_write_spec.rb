require 'pathname'
require_relative '../../spec_helper'

opts = {
  proxy: 'wavefront.localnet',
}

describe '#run' do
end

describe '#load_data' do
  k = Wavefront::Cli::BatchWrite.new(opts, 'write')

  it 'loads in a data file' do
    expect(k.load_data(Pathname.new(__FILE__).dirname + 'resources' +
                       'write.parabola').length).to eq(784)
  end

  it 'raises an error if the file does not exist' do
    expect{k.load_data(Pathname.new('/no/such/file'))}.to raise_exception(
      RuntimeError)
  end
end

describe '#tags_to_hash' do
  k = Wavefront::Cli::BatchWrite.new(opts, 'write')

  it 'parses a single tag' do
    expect(k.tags_to_hash('key=value')).to eq(key: 'value')
  end

  it 'parses multiple tags' do
    expect(k.tags_to_hash(['k1=v1', 'k2=v2', 'k3=v3'])).to eq(
      {k1: 'v1', k2: 'v2', k3: 'v3'})
  end

  it 'skips tags with no value' do
    expect(k.tags_to_hash(['k1=v1', 'k2v2', 'k3=v3'])).to eq(
      {k1: 'v1', k3: 'v3'})
  end

  it 'handles tags containing an "="' do
    expect(k.tags_to_hash(['k1=v1', 'k2=^=^', 'k3=v3'])).to eq(
      {k1: 'v1', k2: '^=^', k3: 'v3'})
  end

  it 'silently handles things which are not arrays' do
    expect(k.tags_to_hash({})).to eq({})
  end

  it 'deals with quoted tags' do
    expect(k.tags_to_hash(["'k1'='v1'", '"k2"="v2"', 'k3="v3"'])).to eq(
      {k1: 'v1', k2: 'v2', k3: 'v3'})
  end
end

describe '#process_filedata' do
end

describe '#valid_format?' do
  k = Wavefront::Cli::BatchWrite.new(opts, 'write')
  context 'valid format strings' do
    %w(v vT tv tvT mv vm mvt mtv tmv mvT vmT mvtT tmvT).each do |fmt|
      it 'accepts #{fmt}' do
        expect(k.valid_format?(fmt)).to be true
      end
    end
  end

  context 'invalid format strings' do
    %w(Tmv m mvTt amv mmv vv mvTm).each do |fmt|
      it "rejects #{fmt}" do
        expect(k.valid_format?(fmt)).to be_falsey
      end
    end
  end
end

describe '#valid_line?' do
  context 'using four columns including points tags' do
    k = Wavefront::Cli::BatchWrite.new(opts, 'write')
    k.setup_fmt('mtvT')

    it 'accepts four columns' do
      expect(k.valid_line?('metric time value TAG1')).to be true
    end

    it 'accepts six columns' do
      expect(k.valid_line?('metric time value TAG1 TAG2 TAG3')).to be true
    end

    it 'rejects three columns' do
      expect(k.valid_line?('metric time value')).to be false
    end
  end

  context 'using two columns, not including points tags' do
    k = Wavefront::Cli::BatchWrite.new(opts, 'write')
    k.setup_fmt('mv')

    it 'accepts two columns' do
      expect(k.valid_line?('metric value')).to be true
    end

    it 'rejects three columns' do
      expect(k.valid_line?('metric time TAG1')).to be false
    end

    it 'rejects one column' do
      expect(k.valid_line?('metric')).to be false
    end
  end
end

describe '#valid_timestamp?' do
  k = Wavefront::Cli::BatchWrite.new(opts, 'write')

  it 'accepts a valid timestamp as an integer' do
    expect(k.valid_timestamp?(Time.now.to_i)).to be true
  end

  it 'accepts a valid timestamp as a string' do
    expect(k.valid_timestamp?(Time.now.to_i.to_s)).to be true
  end

  it 'rejects a timestamp too far in the past' do
    expect(k.valid_timestamp?(Time.new('1999-12-31').to_i)).to be false
  end

  it 'rejects a timestamp too far in the future' do
    expect(k.valid_timestamp?((Date.today + 367).to_time.to_i)).to be false
  end
end

describe '#valid_value?' do
  k = Wavefront::Cli::BatchWrite.new(opts, 'write')
  context 'numerics' do
    [-1, 0, 10, 1e6, 3.14].each do |n|
      it "accepts #{n}" do
        expect(k.valid_value?(n)).to be true
      end
    end
  end

  context 'strings' do
    %w(-1 0 10 1e6 3.14).each do |n|
      it "accepts #{n}" do
        expect(k.valid_value?(n)).to be_truthy
      end
    end

    %w(1-2 a --6 1.2.3).each do |s|
      it "rejects #{s}" do
        expect(k.valid_value?(s)).to be_falsey
      end
    end
  end
end

describe '#process_line' do

  context 'without metric prefix' do
    k = Wavefront::Cli::BatchWrite.new(opts, 'write')
    k.setup_opts(opts)

    it 'processes a four-field line' do
      k.setup_fmt('mtvT')
      expect(k.process_line('test_metric 1470176262 1234 t1="v1"')).to eq(
        { path:   'test_metric',
          ts:     Time.at(1470176262),
          source: HOSTNAME,
          value:  1234,
          tags:   { t1: 'v1' }
      })
    end

    it 'processes a four-field line with multiple tags' do
      k.setup_fmt('mtvT')
      expect(k.process_line('test_metric 1470176262 3.14 t1=v1 t2=v2 t3=v3')
            ).to eq(
        { path:   'test_metric',
          ts:     Time.at(1470176262),
          source: HOSTNAME,
          value:  3.14,
          tags:   { t1: 'v1', t2: 'v2', t3: 'v3' }
         })
    end

    it 'skips a blank line' do
      expect(k.process_line('')).to be true
    end

    it 'rejects a three-field line when expecting two fields' do
      k.setup_fmt('mvt')
      expect(k.process_line('3 1470176262')).to be false
      expect{k.process_line('3 1470176262')}.to match_stdout(
        'WARNING: wrong number of fields. Skipping.')
    end

    it 'ignores dodgy tags' do
      k.setup_fmt('mtvT')
      expect(k.process_line('test_metric 1470176262 3.14 bad_tag')).to eq(
        { path:   'test_metric',
          ts:     Time.at(1470176262),
          source: HOSTNAME,
          value:  3.14,
          tags:   {}
      })
    end
  end

  context 'with metric prefix' do
    k = Wavefront::Cli::BatchWrite.new(opts, 'write')
    k.setup_opts(metric: 'test_metric_3')

    it 'rejects a two-field line with the fields backwards' do
      k.setup_fmt('vt')
      expect(k.process_line('1470176262 3.14')).to be false
      expect{k.process_line('1470176262 3.14')}.to match_stdout(
        "WARNING: invalid timestamp '3.14'. Skipping.")
    end

    it 'rejects a two-field line with an invalid value' do
      k.setup_fmt('vt')
      expect(k.process_line('x 1470176262')).to be false
      expect{k.process_line('x 14701762624')}.to match_stdout(
        "WARNING: invalid value 'x'. Skipping.")
    end

    it 'processes a two-field line with a CLI metric path' do
      k.setup_fmt('tv')
      expect(k.process_line('1470176262 3.14')
            ).to eq(
        { path:   'test_metric_3',
          ts:     Time.at(1470176262),
          source: HOSTNAME,
          value:  3.14,
      })
    end

    it 'processes a two-field line with spacey tags' do
      k.setup_fmt('tvT')
      expect(k.process_line('1470176262 3.14 t1="value 1" t2="value 2"')
            ).to eq(
        { path:   'test_metric_3',
          ts:     Time.at(1470176262),
          source: HOSTNAME,
          value:  3.14,
          tags:   { t1: 'value 1', t2: 'value 2' }
      })
    end
  end
end
