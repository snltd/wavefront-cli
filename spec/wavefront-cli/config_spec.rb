#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'minitest/autorun'
require_relative '../constants'
require_relative '../../lib/wavefront-cli/config'
require_relative '../support/command_base'

DEF_CF = Pathname.new(Dir.home).join('.wavefront')
CONF_TMP = Pathname.new('/tmp/outfile')
CMD_PATH = Pathname.new(__FILE__)

# Test CLI configuration command
#
class WavefrontCliConfigTest < Minitest::Test
  attr_reader :wf, :wfo, :wfn

  def setup
    blank_envvars
    @wf = WavefrontCli::Config.new({})
    @wfo = WavefrontCli::Config.new(config: CF)
    @wfn = WavefrontCli::Config.new(config: '/no/file')
  end

  def test_do_location
    assert_equal(DEF_CF, wf.do_location)
    assert_equal(Pathname('/no/file'), wfn.do_location)
    assert_equal(CF, wfo.do_location)
  end

  def test_do_profiles
    assert_equal(%w[default other], wfo.do_profiles)

    assert_raises(WavefrontCli::Exception::ConfigFileNotFound) do
      wfn.do_profiles
    end
  end

  def test_do_show
    assert_equal(File.read(CF), wfo.do_show)
    # assert_empty(err)
    # assert out.start_with?("[default]\n")
    # assert_equal(10, out.split("\n").size)
  end

  def test_input_prompt
    assert_equal('  Token:> ', wf.input_prompt('Token', nil))
    assert_equal('  Proxy [proxy]:> ', wf.input_prompt('Proxy', 'proxy'))
  end

  def test_read_input
    ["value  \n", " value\n", "    value  \t\n", "value\n"].each do |v|
      $stdin.stub(:gets, v) { assert_equal('value', wf.read_input) }
    end
  end

  def test_base_config
    out, err = capture_io { assert_instance_of(IniFile, wf.base_config) }
    assert_empty(err)

    if Pathname.new(Dir.home).join('.wavefront').exist?
      assert_empty(out)
    else
      assert_match(/Creating new configuration file at/, out)
    end

    out, err = capture_io { assert_instance_of(IniFile, wfo.base_config) }
    assert_empty(err)
    assert_empty(out)

    assert_output('') { wfo.base_config }
    assert_output("Creating new configuration file at /no/file.\n") do
      wfn.base_config
    end
  end

  def test_validate_thing_input
    assert_equal('str', wf.validate_thing_input('str', nil,
                                                proc { |v| v.is_a?(String) }))

    assert_equal('defval', wf.validate_thing_input('', 'defval',
                                                   proc { |v|
                                                     v.is_a?(String)
                                                   }))

    assert_raises(WavefrontCli::Exception::MandatoryValue) do
      wf.validate_thing_input('', nil, proc { |v| v.is_a?(String) })
    end

    assert_raises(WavefrontCli::Exception::InvalidValue) do
      wf.validate_thing_input(:symbol, nil, proc { |v| v.is_a?(String) })
    end

    assert_raises(WavefrontCli::Exception::InvalidValue) do
      wf.validate_thing_input('', 123, proc { |v| v.is_a?(String) })
    end
  end

  def test_create_profile_1
    input_list = %w[2501b9c3-61e3-4f07-bee2-250aa06a9cab
                    test.wavefront.com myproxy json]

    out, err = capture_io do
      x = wfo.stub(:read_input, proc { input_list.shift }) do
        wfo.create_profile('prof')
      end

      assert_instance_of(IniFile, x)
      assert_equal('2501b9c3-61e3-4f07-bee2-250aa06a9cab',
                   x[:prof]['token'])
      assert_equal('test.wavefront.com', x[:prof]['endpoint'])
      assert_equal('myproxy', x[:prof]['proxy'])
      assert_equal('json', x[:prof]['format'])
    end

    assert_empty(err)
    assert_match(/Creating profile 'prof'./, out)
    assert_match(/Wavefront API token/, out)
    assert_match(/Wavefront API endpoint/, out)
    assert_match(/Wavefront proxy endpoint/, out)
    assert_match(/default output format/, out)
  end

  def test_create_profile_2
    input_list = ['2501b9c3-61e3-4f07-bee2-250aa06a9cab', '', '', '']

    out, err = capture_io do
      x = wfo.stub(:read_input, proc { input_list.shift }) do
        wfo.create_profile('prof')
      end

      assert_instance_of(IniFile, x)
      assert_equal('2501b9c3-61e3-4f07-bee2-250aa06a9cab',
                   x[:prof]['token'])
      assert_equal('metrics.wavefront.com', x[:prof]['endpoint'])
      assert_equal('wavefront', x[:prof]['proxy'])
      assert_equal('human', x[:prof]['format'])
    end

    assert_empty(err)
    assert_match(/Creating profile 'prof'./, out)
    assert_match(/Wavefront API token/, out)
    assert_match(/Wavefront API endpoint/, out)
    assert_match(/Wavefront proxy endpoint/, out)
    assert_match(/default output format/, out)
  end

  def test_create_profile_3
    input_list = ['X501b9c3-61e3-4f07-bee2-250aa06a9cab', '', '', '']

    out, err = capture_io do
      assert_raises(WavefrontCli::Exception::InvalidValue) do
        wfo.stub(:read_input, proc { input_list.shift }) do
          wfo.create_profile('prof')
        end
      end
    end

    assert_empty(err)
    assert_match(/Creating profile 'prof'./, out)
    assert_match(/Wavefront API token/, out)
  end

  def test_create_profile_4
    input_list = ['2501b9c3-61e3-4f07-bee2-250aa06a9cab', 'end', '', '']

    out, err = capture_io do
      assert_raises(WavefrontCli::Exception::InvalidValue) do
        wfo.stub(:read_input, proc { input_list.shift }) do
          wfo.create_profile('prof')
        end
      end
    end

    assert_empty(err)
    assert_match(/Creating profile 'prof'./, out)
    assert_match(/Wavefront API token/, out)
  end

  def test_create_profile_5
    input_list = ['', '', '', '']

    out, err = capture_io do
      assert_raises(WavefrontCli::Exception::MandatoryValue) do
        wfo.stub(:read_input, proc { input_list.shift }) do
          wfo.create_profile('prof')
        end
      end
    end

    assert_empty(err)
    assert_match(/Creating profile 'prof'./, out)
    assert_match(/Wavefront API token/, out)
  end

  def test_do_setup; end

  def test_delete_section
    wfo.delete_section('default', CONF_TMP)
    assert_equal(
      "[other]\ntoken = abcdefab-0123-abcd-0123-abcdefabcdef\n" \
      "endpoint = other.wavefront.com\nproxy = otherwf.localnet\n\n",
      File.read(CONF_TMP)
    )

    assert_raises(WavefrontCli::Exception::ProfileNotFound) do
      wfo.delete_section('nosuchprofile', CONF_TMP)
    end
  end

  def test_do_envvars_all_unset
    assert_equal(['WAVEFRONT_ENDPOINT   unset',
                  'WAVEFRONT_TOKEN      unset',
                  'WAVEFRONT_PROXY      unset'], wfo.do_envvars)
  end

  def test_do_envvars_proxy_set
    ENV['WAVEFRONT_PROXY'] = 'myproxy'

    assert_equal(['WAVEFRONT_ENDPOINT   unset',
                  'WAVEFRONT_TOKEN      unset',
                  'WAVEFRONT_PROXY      myproxy'], wfo.do_envvars)
  end

  def test_do_envvars_proxy_and_token_set
    ENV['WAVEFRONT_PROXY'] = 'myproxy'
    ENV['WAVEFRONT_TOKEN'] = 'token'

    assert_equal(['WAVEFRONT_ENDPOINT   unset',
                  'WAVEFRONT_TOKEN      token',
                  'WAVEFRONT_PROXY      myproxy'], wfo.do_envvars)
  end

  def test_present?
    assert wfo.present?
    assert_raises(WavefrontCli::Exception::ConfigFileNotFound) do
      wfn.present?
    end
  end

  def test__config_file
    assert_equal(DEF_CF, wf._config_file)
    assert_equal(Pathname.new(CF), wfo._config_file)
  end

  def test_read_config
    assert_instance_of(IniFile, wfo.read_config)
  end

  def blank_envvars
    %w[WAVEFRONT_ENDPOINT WAVEFRONT_PROXY WAVEFRONT_TOKEN].each do |v|
      ENV[v] = nil
    end
  end
end

class ConfigEndToEndTest < EndToEndTest
  def test_location
    assert_output("#{Pathname.new(Dir.home).join('.wavefront')}\n", '') do
      wf.new('config location'.split)
    end
  end

  def test_profiles
    assert_output("default\nother\n", '') do
      wf.new("config profiles -c #{CF}".split)
    end
  end

  def test_envvars
    out, err = capture_io { wf.new('config envvars'.split) }
    assert_equal(3, out.lines.count)
    assert_empty err
    assert_match(/^WAVEFRONT_ENDPOINT /, out)
    assert_match(/^WAVEFRONT_TOKEN /, out)
    assert_match(/^WAVEFRONT_PROXY /, out)
  end

  def test_cluster
    assert_abort_on_missing_creds('cluster')
    quietly { assert_cmd_gets('cluster', '/api/v2/cluster/info') }
  end

  def test_about
    out, err = capture_io { wf.new('config about'.split) }
    lines = out.lines

    assert_match(/^wf version *#{WF_CLI_VERSION}$/o, lines[0])
    assert lines[1].start_with?('wf path')
    assert lines[2].start_with?('SDK version')
    assert lines[3].start_with?('SDK location')
    assert lines[4].start_with?('Ruby version')
    assert lines[5].start_with?('Ruby platform')
    assert_empty err
  end

  private

  def cmd_word
    'config'
  end
end
