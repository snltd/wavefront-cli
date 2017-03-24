require_relative '../../spec_helper'
require 'pathname'
require 'json'

# Valid alert states as defined in alerting.rb
#
states = %w(active affected_by_maintenance all invalid snoozed)
formats = %w(ruby json human)

opts = {
  token:    TEST_TOKEN,
  endpoint: TEST_HOST,
}

describe Wavefront::Cli::Alerts do

  describe '#prep_time' do

    [Time.now, 1469826353, 1469826353000,
     '2016-07-29 22:05:51 +0100', '12:00', '2001-01-01'].each do |t|
      it "converts time like '#{t}' (#{t.class}) into epoch ms" do
        opts[:start] = t
        k = Wavefront::Cli::Events.new(opts, [])
        expect(k.prep_time(:start)).to be_kind_of(Numeric)
        expect(k.prep_time(:start)).to be > 978307000000
      end
    end
  end

  describe '#prep_hosts' do
    k = Wavefront::Cli::Events.new(opts, [])
    k.hostname = 'this-host'

    it 'returns the local hostname if nothing is given' do
      expect(k.prep_hosts).to eq ['this-host']
    end

    it 'returns multiple hosts if an array is passed' do
      expect(k.prep_hosts('host-a,host-b,host-c')).to eq(
        ['host-a', 'host-b', 'host-c'])
    end
  end

end
