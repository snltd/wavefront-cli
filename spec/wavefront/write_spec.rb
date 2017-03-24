require_relative '../../spec_helper'
require 'socket'

opts = {
  proxy: 'wavefront.localnet',
}
args = 'write'
k = Wavefront::Cli::Write.new(opts, args)

describe '#write_metric' do
  it 'writes a point to a socket' do
    socket = Mocket.new
    allow(TCPSocket).to receive(:new).and_return(socket)
    now = Time.now
    expect(socket).to receive(:puts).with(
      "1234 test.metric #{now.to_i} host=testhost")
    k.write_metric('test.metric', '1234', {
      timestamp: now, host_name: 'testhost'})
  end

  it 'writes a point with tags to a socket' do
    socket = Mocket.new
    allow(TCPSocket).to receive(:new).and_return(socket)
    now = Time.now
    expect(socket).to receive(:puts).with(
      "5678 test.metric2 #{now.to_i} host=testhost t1=\"v1\" t2=\"v2\"")
    k.write_metric('test.metric2', '5678', {
      timestamp: now, host_name: 'testhost', point_tags:
      {t1: 'v1', t2: 'v2'}})
  end
end

describe '#valid_host?' do

  it 'accepts valid hostnames' do
    expect(k.valid_host?('valid-host')).to be_truthy
  end

  it 'rejects invalid hostnames' do
    expect(k.valid_host?('!nval!d_HOST')).to be_falsey
    expect(k.valid_host?('a' * 1025)).to be_falsey
  end

end

describe '#valid_value?' do

  it 'accepts real numbers' do
    expect(k.valid_value?(123)).to be true
    expect(k.valid_value?(-123)).to be true
    expect(k.valid_value?(1.23)).to be true
    expect(k.valid_value?(1.5e07)).to be true
  end

  it 'accepts integer-type strings' do
    expect(k.valid_value?('123')).to be true
    expect(k.valid_value?('-123')).to be true
  end

  it 'accepts exponential-type strings' do
    expect(k.valid_value?('1.23e06')).to be true
    expect(k.valid_value?('-1.23e06')).to be true
  end

  it 'rejects random strings' do
    %w(abc 1.2.3 1.2e2e3 6e).each do |str|
      expect{k.valid_value?(str)}.to raise_exception(
       Wavefront::Exception::InvalidMetricValue)
    end
  end
end

describe '#valid_metric?' do
  it 'accepts some valid metrics' do
    expect(k.valid_metric?('valid.metric.path')).to be true
    expect(k.valid_metric?('valid.metric-path')).to be true
    expect(k.valid_metric?('valid.metric_path')).to be true
  end

  it 'rejects non-strings' do
    [123, {k: 'v'}, []].each do |el|
      expect{k.valid_metric?(el)}.to raise_exception(
       Wavefront::Exception::InvalidMetricName)
    end
  end

  it 'rejects too-long paths' do
    expect{k.valid_metric?('aaaa.' * 300 )}.to raise_exception(
       Wavefront::Exception::InvalidMetricName)
  end

  it 'rejects single-element paths' do
      expect{k.valid_metric?('metric')}.to raise_exception(
       Wavefront::Exception::InvalidMetricName)
  end

  it 'rejects invalid characters' do
    expect{k.valid_metric?('!nval!d.metric')}.to raise_exception(
       Wavefront::Exception::InvalidMetricName)
  end
end

describe '#prep_tags' do
  it 'handles invalid input' do
    expect(k.prep_tags('string')).to eq([])
    expect(k.prep_tags({key: 'val'})).to eq([])
    expect(k.prep_tags(['badtag1', 'badtag2'])).to eq([])
  end

  it 'handles sample valid input' do
    expect(k.prep_tags(['key1=val1', 'key2=val2'])).to eq(
      [['key1', 'val1'], ['key2', 'val2']])
  end
end
