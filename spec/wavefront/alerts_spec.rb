require_relative '../../spec_helper'
require 'pathname'
require 'json'
require 'erb'

# Valid alert states as defined in alerting.rb
#
states = %w(active affected_by_maintenance all invalid snoozed)
formats = %w(ruby json human yaml)

opts = {
  token:    TEST_TOKEN,
  endpoint: TEST_HOST,
}

describe Wavefront::Cli::Alerts do

  describe '#run' do

    it 'raises an exception if there are no arguments' do
      k = Wavefront::Cli::Alerts.new(opts, [])
      expect{k.run}.to raise_exception('Missing query.')
    end
  end

  describe '#valid_state?' do
    wfa = Wavefront::Alerting.new(TEST_TOKEN)

    it 'raises an exception if the alert type is invalid' do
      k = Wavefront::Cli::Alerts.new(opts, ['all'])
      expect{k.valid_state?(wfa, 'nosuch_alert')}.to raise_exception(
        RuntimeError, "State must be one of: #{states.join(', ')}.")
    end

    it 'accepts all valid states' do
      k = Wavefront::Cli::Alerts.new(opts, ['all'])

      states.each do |state|
        expect(k.valid_state?(wfa, state)).to be(true)
      end
    end
  end

  describe '#valid_format?' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])

    it 'accepts valid formats as symbols and strings' do
      formats.each do |fmt|
        expect(k.valid_format?(fmt)).to be(true)
        expect(k.valid_format?(fmt.to_s)).to be(true)
      end
    end

    it 'raises an exception on an invalid format' do
      expect{k.valid_format?('junk')}.to raise_exception( RuntimeError,
        "Output format must be one of: #{formats.join(', ')}.")
    end
  end

  describe '#format_result' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])
    res = "{\n  \"a\": 1,\n  \"b\": 2\n}"

    it 'raises an error on unknown type' do
      expect{k.format_result(res, :nonsense)}.to raise_exception(RuntimeError)
    end

    it 'pretty-prints when requested' do
      expect{k.format_result(res, :ruby)}.to match_stdout(
        "[{\n  \"a\": 1,\n  \"b\": 2\n}]")
    end

    it 'prints as JSON when requested' do
      expect{k.format_result(res, :json)}.to match_stdout(res)
    end

    it 'reconstructs JSON output' do
      src = IO.read(Pathname.new(__FILE__).dirname + 'resources' +
                'alert.raw')
      out = IO.read(Pathname.new(__FILE__).dirname + 'resources' +
                'alert.json')
      expect{k.format_result(src, :json)}.to match_stdout(out)
    end
  end

  describe '#humanize' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])
    src = IO.read(Pathname.new(__FILE__).dirname + 'resources' +
                  'alert.raw')
    #
    # The output has to get munged a bit here because it turns out
    # that comparing multi-line things isn't anywhere near so
    # straightforward as I expected.
    #
    it 'reconstructs human output' do
      out = ERB.new(IO.read(Pathname.new(__FILE__).dirname +
                            'resources' + 'alert.human.erb')).result
      expect(k.humanize(JSON.parse(src)).join("\n")).to eq(out)
    end
  end

  describe '#human_line' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])
    it 'prints in the correct format' do
      expect(k.human_line('desc', 123)).to eq('desc                  123')
    end
  end

  describe '#human_line_created' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])
    it 'prints in the correct format' do
      expect(k.human_line_created('time', 1469804504000)).to eq(
        "time                  #{Time.at(1469804504)} (1469804504000)")
    end
  end

  describe '#human_line_hostsUsed' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])

    it 'just prints the header if there are no hosts' do
      expect(k.human_line_hostsUsed('host', false)).to eq('host')
      expect(k.human_line_hostsUsed('host', [])).to eq('host')
      expect(k.human_line_hostsUsed('host', {})).to eq('host')
    end

    it 'prints in the correct format for a single host' do
      expect(k.human_line_hostsUsed('host', ['hostname'])).to eq(
        ['host                  hostname'])
    end

    it 'prints in the correct format for a multiple hosts' do
      expect(k.human_line_hostsUsed('host', ['host1', 'host2'])).to eq(
        ['host                  host1', '                      host2'])
    end
  end

  describe '#indent_wrap' do
    k = Wavefront::Cli::Alerts.new(opts, ['all'])

    it 'leaves short strings unchanged' do
      expect(k.indent_wrap('short string')).to eq("short string")
    end

    it 'wraps long strings with a hanging indent' do
      expect(k.indent_wrap('lots and lots of words which are ' +
             'altogether far too wide for an 80 column terminal to ' +
             'display without breaking at least once, especially with ' +
             'a hanging indent')).to eq(
"lots and lots of words which are altogether far too wide
                      for an 80 column terminal to display without breaking at
                      least once, especially with a hanging indent")
    end
  end
end
