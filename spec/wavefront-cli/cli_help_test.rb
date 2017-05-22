#!/usr/bin/env ruby

require_relative '../../lib/wavefront-cli'
require_relative '../spec_helper'

# Be sure the CLI behaves properly when people ask for help
#
class WavefrontCliHelpTest < MiniTest::Test

  def test_no_args
    begin
      WavefrontCommand.new([])
    rescue SystemExit => e
      assert_equal(1, e.status)
      assert_match(/^Usage/, e.message)
      assert_match(/^  wavefront --version$/, e.message)
      assert_match(/^  wavefront --help$/, e.message)
    end
  end

  def test_version
    begin
      WavefrontCommand.new(%w(--version))
    rescue SystemExit => e
      assert_equal(1, e.status)
      assert_match(/^\d+\.\d+\.\d+$/, e.message)
    end
  end

  def test_help
    begin
      WavefrontCommand.new(%w(--help))
    rescue SystemExit => e
      assert_equal(1, e.status)
      assert_match(/^Commands:$/, e.message)
      CMDS.each do |cmd|
        assert_match(/^  #{cmd} /, e.message)
      end
    end
  end

  def test_command_help
    CMDS.each do |cmd|
      begin
        WavefrontCommand.new([cmd, '--help'])
      rescue SystemExit => e
        assert_equal(1, e.status)
        assert_match(/^Usage:/, e.message)
        assert_match(/^  #{CMD} #{cmd} /, e.message)
        assert_match(/^  #{CMD} #{cmd} --help$/, e.message)
      end
    end
  end
end
=begin
class WavefrontCliHelpTest < MiniTest::Test
  def test_usage_no_args
    x = wf
    assert_equal(1, x.status)
    assert_match('--help', x.stderr)
    assert_empty(x.stdout)
  end

  def test_usage_no_args
    x = wf '--version'
    assert_equal(1, x.status)
    assert_match(/^\d+\.\d+\.\d+$/, x.stderr)
    assert_empty(x.stdout)
  end

  def test_help
    x = wf '--help'
    assert_equal(1, x.status)
    CMDS.each { |cmd| assert_match(/^  #{cmd} /, x.stderr) }
    assert_empty(x.stdout)
  end

  def test_cmd_usage
    CMDS.each do |cmd|
      x = wf "#{cmd} --help"
    assert_equal(1, x.status)
    assert_match(/^Options:/, x.stderr)
    assert_empty(x.stdout)
    end
  end

end
=end

=begin

# Things from the sample config file, for shorthand
#
DEF_TOKEN = '12345678-abcd-1234-abcd-123456789012'
OTHER_TOKEN = 'abcdefab-0123-abcd-0123-abcdefabcdef'

# Some standard start and end times
#
TIME = {
  start: {
    eng: '12:00',
    i:    DateTime.parse('12:00').to_time.to_i,
    ms:   DateTime.parse('12:00').to_time.to_i * 1000
  },
  end: {
    eng: '12:05',
    i:    DateTime.parse('12:05').to_time.to_i,
    ms:   DateTime.parse('12:05').to_time.to_i * 1000
  }
}

describe 'dashboard mode' do
  cmds = %W(list import export create clone delete undelete
            history).each do |cmd|
    it "#{cmd} fails with no token if there is no token" do
      args = 'arg1'
      args = '' if cmd == 'list'
      args = 'arg1 arg2 arg3' if cmd == 'clone'
      args = 'arg1 arg2' if cmd == 'create'
      o = wf("dashboard #{cmd} -c/nf #{args}")
      expect(o.status).to eq(1)
      expect(o.stderr).to eq(
        'dashboard query failed. Please supply an API token.')
      expect(o.stdout).to eq(
        "config file '/nf' not found. Taking options from command-line.")
    end
  end

  describe 'list subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('dashboard -c /nf -n -t token list')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to match(
        'GET https://metrics.wavefront.com/api/dashboard')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with default config file options' do
      o = wf("dashboard -c #{CF} -n -T tag1 list")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {:\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
      expect(o.stdout_a[-2]).to start_with(
        'GET https://default.wavefront.com/api/dashboard/')
      expect(o.stdout_a[-2]).to have_element([:customerTag, 'tag1'])
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with config file and CLI options' do
      o = wf("dashboard -c #{CF} -P other -n list -a")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"abcdefab-0123-abcd-0123-abcdefabcdef"}')
      expect(o.stdout_a[-2]).to start_with(
        'GET https://other.wavefront.com/api/dashboard/')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end
  end

  describe 'import subcommand' do
    it 'errors safely on a non-existent file' do
      o = wf("dashboard -c #{CF} -t token import /no/such/file")
      expect(o.stdout).to be_empty
      expect(o.status).to eq(1)
      expect(o.stderr).to eq(
        'dashboard query failed. Import file does not exist.')
    end

    it 'errors safely on an unsupported file type' do
      o = wf("dashboard -c #{CF} -t token import #{RES_DIR +
             'sample_dash.txt'}")
      expect(o.stdout).to be_empty
      expect(o.status).to eq(1)
      expect(o.stderr).to eq(
        'dashboard query failed. Unsupported file format.')
    end

    it 'performs a verbose no-op with a JSON import file' do
      o = wf("dashboard -c #{CF} -n -t token import #{RES_DIR +
             'sample_dash.json'}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://default.wavefront.com/api/dashboard/?rejectIfExists=true')
      expect(o.stdout_a[-2]).to start_with(
        'QUERY {"customer":"sysdef","url":"internal_metrics"')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a YAML import file' do
      o = wf("dashboard -c #{CF} -P other -n -F import #{RES_DIR +
             'sample_dash.yaml'}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://other.wavefront.com/api/dashboard/')
      expect(o.stdout_a[-2]).to start_with(
        'QUERY {"customer":"sysdef","url":"internal_metrics"')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"abcdefab-0123-abcd-0123-abcdefabcdef"}')
    end
  end

  describe 'export subcommand' do
    it 'performs a verbose no-op with options' do
      o = wf("dashboard -E endpoint.wavefront.com -n -t token export mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('GET ' \
        'https://endpoint.wavefront.com/api/dashboard/mydash')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a config file' do
      o = wf("dashboard -c #{CF} -n export mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('GET ' \
        'https://default.wavefront.com/api/dashboard/mydash')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end
  end

  describe 'create subcommand' do
    it 'performs a verbose no-op with defaults' do
      o = wf("dashboard -t token -n create test_id \"test name\"")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://metrics.wavefront.com/api/dashboard/test_id/create')
      expect(o.stdout_a[-2]).to eq('QUERY name=test%20name')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a config file' do
      o = wf("dashboard -c #{CF} -P other -n create test_id \"test name\"")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://other.wavefront.com/api/dashboard/test_id/create')
      expect(o.stdout_a[-2]).to eq('QUERY name=test%20name')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"abcdefab-0123-abcd-0123-abcdefabcdef"}')
    end
  end

  describe 'clone subcommand' do
    it 'performs a verbose no-op with defaults' do
      o = wf('dashboard clone -t token -n src_id new_id "new name"')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://metrics.wavefront.com/api/dashboard/src_id/clone')
      expect(o.stdout_a[-2]).to eq('QUERY name=new%20name&url=new_id')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with config file' do
      o = wf("dashboard clone -c #{CF} -n src_id new_id 'new name'")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://default.wavefront.com/api/dashboard/src_id/clone')
      expect(o.stdout_a[-2]).to eq('QUERY name=new%20name&url=new_id')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end

    it 'performs a verbose no-op with options and config file' do
      o = wf("dashboard clone -E endpoint.wavefront.com -c #{CF} " \
             '-v 14 -P other -n src_id new_id "new name"')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://endpoint.wavefront.com/api/dashboard/src_id/clone')
      expect(o.stdout_a[-2]).to eq('QUERY name=new%20name&url=new_id&v=14')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"abcdefab-0123-abcd-0123-abcdefabcdef"}')
    end
  end

  describe 'delete subcommand' do
    it 'performs a verbose no-op with options ' do
      o = wf(
        'dashboard -E endpoint.wavefront.com -t token -n delete mydash')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('POST ' \
        'https://endpoint.wavefront.com/api/dashboard/mydash/delete')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a config file' do
      o = wf("dashboard -c #{CF} -n delete mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('POST ' \
        'https://default.wavefront.com/api/dashboard/mydash/delete')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end
  end

  describe 'undelete subcommand' do
    it 'performs a verbose no-op with options ' do
      o = wf(
        'dashboard -E endpoint.wavefront.com -t token -n undelete mydash')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('POST ' \
        'https://endpoint.wavefront.com/api/dashboard/mydash/undelete')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a config file' do
      o = wf("dashboard -c #{CF} -n undelete mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('POST ' \
        'https://default.wavefront.com/api/dashboard/mydash/undelete')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end
  end


  describe 'history subcommand' do
    it 'performs a verbose no-op with no options' do
      o = wf('dashboard -t token -n history mydash')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('GET https://metrics.wavefront.com/' \
        'api/dashboard/mydash/history?start=100')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end
  end

  describe 'history subcommand' do
    it 'performs a verbose no-op with config file' do
      o = wf("dashboard -c #{CF} -S 10 -n history mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('GET https://default.wavefront.com/' \
        'api/dashboard/mydash/history?start=10')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end
  end

  describe 'history subcommand' do
    it 'performs a verbose no-op with config file and options' do
      o = wf("dashboard -c #{CF} -P other -S 10 -L 5 -n history mydash")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('GET https://other.wavefront.com/' \
        'api/dashboard/mydash/history?start=10&limit=5')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"abcdefab-0123-abcd-0123-abcdefabcdef"}')
    end

  end
end

describe 'usage' do
  commands = %w(alerts event source ts write)

  it 'prints usage and exits 1 with no args' do
    o = wf
    expect(o.stdout).to be_empty
    expect(o.stderr_a.first).to eq('Usage:')
    expect(o.status).to eq(1)
  end

  it 'prints detailed usage with --help' do
    o = wf('--help')
    expect(o.stdout).to be_empty
    expect(o.stderr_a.first).to eq('Wavefront CLI')
    expect(o.status).to eq(1)
    commands.each { |cmd| expect(o.stderr).to match(/\n  #{cmd} /) }
  end

  commands.each do |cmd|
    it "prints help for the #{cmd} command" do
      o = wf("#{cmd} --help")
      expect(o.status).to eq(1)
      expect(o.stdout).to be_empty
      expect(o.stderr_a.first).to eq('Usage:')
      expect(o.stderr_a).to include('Global options:')
    end
  end

  it 'displays the correct version number' do
    include Wavefront::Client
    o = wf('--version')
    expect(o.status).to eq(1)
    expect(o.stdout).to be_empty
    expect(o.stderr).to eq(Wavefront::Client::VERSION)
  end
end

describe 'alerts mode' do

  describe 'export subcommand' do
    it 'performs a verbose noop with a CLI token' do
      o = wf('alerts -n -t token export 1489152324000')
      expect(o.status).to eq(0)
      expect(o.stderr).to be_empty
      expect(o.stdout_a[-2]).to eq(
        'GET https://metrics.wavefront.com/api/alert/1489152324000')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose noop with a config file and CLI token' do
      o = wf("alerts -c #{CF} -n -t token -f yaml export 1489152324000")
      expect(o.status).to eq(0)
      expect(o.stderr).to be_empty
      expect(o.stdout_a[-2]).to eq(
        'GET https://default.wavefront.com/api/alert/1489152324000')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end
  end

  describe 'import subcommand' do
    it 'errors safely on a non-existent file' do
      o = wf("alerts -c #{CF} -t token import /no/such/file")
      expect(o.stdout).to be_empty
      expect(o.status).to eq(1)
      expect(o.stderr).to eq(
        'alerts query failed. Import file does not exist.')
    end

    it 'errors safely on an unsupported file type' do
      o = wf("alerts -c #{CF} -t token import #{RES_DIR +
             'sample_alert.txt'}")
      expect(o.stdout).to be_empty
      expect(o.status).to eq(1)
      expect(o.stderr).to eq(
        'alerts query failed. Unsupported file format.')
    end

    it 'performs a verbose no-op with a JSON import file' do
      o = wf("alerts -c #{CF} -n -t token import #{RES_DIR +
             'sample_alert.json'}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to have_element([:severity, 'WARN'])
      expect(o.stdout_a[-2]).to have_element([:resolveMinutes, 5])
      expect(o.stdout_a[-2]).to_not have_element([:resolveAfterMinutes, 5])
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://default.wavefront.com/api/alert/create')
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose no-op with a YAML import file' do
      o = wf("alerts -c #{CF} -n -E test.wavefront.com import #{RES_DIR +
             'sample_alert.yaml'}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to have_element([:severity, 'WARN'])
      expect(o.stdout_a[-2]).to have_element([:resolveMinutes, 5])
      expect(o.stdout_a[-2]).to_not have_element([:resolveAfterMinutes, 5])
      expect(o.stdout_a[-3]).to eq('POST ' \
        'https://test.wavefront.com/api/alert/create')
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {:"X-AUTH-TOKEN"=>"12345678-abcd-1234-abcd-123456789012"}')
    end
  end
end

describe 'alerts mode' do
  it 'fails with no token if there is no token' do
    o = wf('alerts -c/nf -E metrics.wavefront.com active')
    expect(o.status).to eq(1)
    expect(o.stderr).to eq('alerts query failed. Please supply an API token.')
    expect(o.stdout).to eq(
      "config file '/nf' not found. Taking options from command-line.")
  end

  it 'fails with a helpful message if an invalid state is given' do
    o = wf('alerts -n -c/nf -t token -E metrics.wavefront.com badstate')
    expect(o.status).to eq(1)
    expect(o.stderr).to eq('alerts query failed. State must be one of: ' \
                'active, affected_by_maintenance, all, invalid, snoozed.')
    expect(o.stdout).to eq("config file '/nf' not found. Taking options " \
                           'from command-line.')
  end

  it 'performs a verbose noop with a CLI endpoint' do
    o = wf('alerts -n -c/nf -t token -E test.wavefront.com active')
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq(
      'GET https://test.wavefront.com/api/alert/active')
  end

  it 'performs a verbose noop with default config file options' do
    o = wf("alerts -n -c #{CF} active")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq(
      'GET https://default.wavefront.com/api/alert/active')
    expect(o.stdout_a.last).to eq(
      "HEADERS {:\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")

  end

  it 'performs a verbose noop with config file and CLI options' do
    o = wf("alerts -n -c #{CF} -E cli.wavefront.com active")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq(
      'GET https://cli.wavefront.com/api/alert/active')
    expect(o.stdout_a.last).to eq(
      "HEADERS {:\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
  end
end

describe 'source mode' do
  cmds = %W(list show describe undescribe #{'tag add'} #{'tag delete'}
            untag).each do |cmd|
    it "#{cmd} fails with no token if there is no token" do
      o = wf("source #{cmd} -c/nf arg1}")
      expect(o.status).to eq(1)
      expect(o.stderr).to eq('source query failed. Please supply an API token.')
      expect(o.stdout).to eq(
        "config file '/nf' not found. Taking options from command-line.")
    end
  end

  describe 'list subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('source -c /nf -n -t token list ptn')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to start_with(
        'GET https://metrics.wavefront.com/api/manage/source/')
      expect(o.stdout_a[-2]).to have_element([:desc, false])
      expect(o.stdout_a[-2]).to have_element([:limit, 100])
      expect(o.stdout_a[-2]).to have_element([:pattern, 'ptn'])
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with default config file options' do
      o = wf("source -c #{CF} -n -s lasthost -l 55 list ptn")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
      expect(o.stdout_a[-2]).to start_with(
        'GET https://default.wavefront.com/api/manage/source/')
      expect(o.stdout_a[-2]).to have_element([:desc, false])
      expect(o.stdout_a[-2]).to have_element([:limit, 55])
      expect(o.stdout_a[-2]).to have_element([:lastEntityId, 'lasthost'])
      expect(o.stdout_a[-2]).to have_element([:pattern, 'ptn'])
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with config file and CLI options' do
      o = wf("source -c #{CF} -P other -n -s lasthost -t token list ptn")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        'HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to start_with(
        'GET https://other.wavefront.com/api/manage/source/')
      expect(o.stdout_a[-2]).to have_element([:desc, false])
      expect(o.stdout_a[-2]).to have_element([:limit, 100])
      expect(o.stdout_a[-2]).to have_element([:lastEntityId, 'lasthost'])
      expect(o.stdout_a[-2]).to have_element([:pattern, 'ptn'])
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end
  end

  describe 'show subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('source -c /nf -n -t token show testhost')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to eq(
        'GET https://metrics.wavefront.com/api/manage/source/testhost')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI options' do
      o = wf('source -c /nf -n -t token -E cli.wavefront.com show testhost')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to eq(
        'GET https://cli.wavefront.com/api/manage/source/testhost')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and config file options' do
      o = wf("source -c #{CF} -n show testhost")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
      expect(o.stdout_a[-2]).to eq(
        'GET https://default.wavefront.com/api/manage/source/testhost')
    end

    it 'performs a verbose noop with CLI and non-default config file options' do
      o = wf("source -c #{CF} -t token -P other -n show testhost")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to eq(
        'GET https://other.wavefront.com/api/manage/source/testhost')
    end
  end

  describe 'describe subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('source -c /nf -n -t token describe "test desc"')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-3]).to eq(
        'POST https://metrics.wavefront.com/api/manage/source/'\
        "#{Socket.gethostname}/description")
      expect(o.stdout_a[-2]).to eq('QUERY test desc')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and config options' do
      o = wf("source -c #{CF} -H i-123456 -n -t token describe 'test desc'")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-3]).to eq(
        'POST https://default.wavefront.com/api/manage/source/'\
        'i-123456/description')
      expect(o.stdout_a[-2]).to eq('QUERY test desc')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and non-default config options' do
      o = wf("source -c #{CF} -P other -E cli.wavefront.com -H i-123456 " \
             "-n describe 'test desc'")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{OTHER_TOKEN}\"}")
      expect(o.stdout_a[-3]).to eq(
        'POST https://cli.wavefront.com/api/manage/source/'\
        'i-123456/description')
      expect(o.stdout_a[-2]).to eq('QUERY test desc')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end
  end

  describe 'undescribe subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('source -c /nf -n -t token undescribe thost')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-3]).to eq(
        'POST https://metrics.wavefront.com/api/manage/source/'\
        'thost/description')
      expect(o.stdout_a[-2]).to eq('QUERY ')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and config options' do
      o = wf("source -c #{CF} -n -t token undescribe thost")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-3]).to eq(
        'POST https://default.wavefront.com/api/manage/source/'\
        'thost/description')
      expect(o.stdout_a[-2]).to eq('QUERY ')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and non-default config options' do
      o = wf("source -n -c #{CF} -P other -E cli.wavefront.com undescribe thost")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{OTHER_TOKEN}\"}")
      expect(o.stdout_a[-3]).to eq(
        'POST https://cli.wavefront.com/api/manage/source/thost/description')
      expect(o.stdout_a[-2]).to eq('QUERY ')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end
  end

  describe 'tag subcommand' do
    describe 'tag add' do
      it 'performs a verbose noop with default options' do
        o = wf('source -c /nf -n -t token tag add tag1 tag2')
        expect(o.stderr).to be_empty
        expect(o.status).to eq(0)
        expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
        expect(o.stdout_a[-2]).to eq(
          'POST https://metrics.wavefront.com/api/manage/source/'\
          "#{Socket.gethostname}/tags/tag2")
        expect(o.stdout_a[-3]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
        expect(o.stdout_a[-4]).to eq(
          'POST https://metrics.wavefront.com/api/manage/source/'\
          "#{Socket.gethostname}/tags/tag1")
        expect(o.stdout).to match(/Taking options from command-line/)
      end

      it 'performs a verbose noop with conf file and CLI options' do
        o = wf("source -c #{CF} -P other -H i-123456 -n " \
               '-E cli.wavefront.com tag add tag1')
        expect(o.stderr).to be_empty
        expect(o.status).to eq(0)
        expect(o.stdout_a[-1]).to eq(
          "HEADERS {\"X-AUTH-TOKEN\"=>\"#{OTHER_TOKEN}\"}")
        expect(o.stdout_a[-2]).to eq(
          'POST https://cli.wavefront.com/api/manage/source/'\
          "i-123456/tags/tag1")
      end
    end

    describe 'tag delete' do
      it 'performs a verbose noop with default options' do
        o = wf('source -c /nf -n -t token tag delete tag1 tag2')
        expect(o.stderr).to be_empty
        expect(o.status).to eq(0)
        expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
        expect(o.stdout_a[-2]).to eq(
          'DELETE https://metrics.wavefront.com/api/manage/source/'\
          "#{Socket.gethostname}/tags/tag2")
        expect(o.stdout_a[-3]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
        expect(o.stdout_a[-4]).to eq(
          'DELETE https://metrics.wavefront.com/api/manage/source/'\
          "#{Socket.gethostname}/tags/tag1")
        expect(o.stdout).to match(/Taking options from command-line/)
      end

      it 'performs a verbose noop with conf file and CLI options' do
        o = wf("source -c #{CF} -P other -H i-123456 -n " \
               '-E cli.wavefront.com tag delete tag1')
        expect(o.stderr).to be_empty
        expect(o.status).to eq(0)
        expect(o.stdout_a[-1]).to eq(
          "HEADERS {\"X-AUTH-TOKEN\"=>\"#{OTHER_TOKEN}\"}")
        expect(o.stdout_a[-2]).to eq(
          'DELETE https://cli.wavefront.com/api/manage/source/'\
          "i-123456/tags/tag1")
      end
    end
  end

  describe 'untag subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('source -c /nf -n -t token untag thost')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-1]).to eq('HEADERS {"X-AUTH-TOKEN"=>"token"}')
      expect(o.stdout_a[-2]).to eq(
        'DELETE https://metrics.wavefront.com/api/manage/source/thost/tags')
      expect(o.stdout).to match(/Taking options from command-line/)
    end

    it 'performs a verbose noop with CLI and config options' do
      o = wf("source -c #{CF} -n -E cli.wavefront.com untag thost1 thost2")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
      expect(o.stdout_a[-4]).to eq(
        'DELETE https://cli.wavefront.com/api/manage/source/thost1/tags')
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
      expect(o.stdout_a[-2]).to eq(
        'DELETE https://cli.wavefront.com/api/manage/source/thost2/tags')
      expect(o.stdout).to_not match(/Taking options from command-line/)
    end
  end
end

describe 'event mode' do
  cmds = %w(create close delete).each do |cmd|
    it "#{cmd} fails with no token if there is no token" do
      o = wf("event #{cmd} -c/nf #{cmd == 'delete' ? 'arg1 arg2' : 'arg1'}")
      expect(o.status).to eq(1)
      expect(o.stderr).to eq('Please supply an API token.')
      expect(o.stdout).to eq(
        "config file '/nf' not found. Taking options from command-line.")
    end
  end

  describe 'create subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf('event create -c/nf -t token -n test_ev')
      expect(o.status).to eq(0)
      expect(o.stderr).to be_empty
      expect(o.stdout_a[-3]).to eq(
        'PUT https://metrics.wavefront.com/api/events/')
      expect(o.stdout_a[-2]).to have_element([:h, Socket.gethostname])
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose noop on a bounded event with CLI options' do
      o = wf("event create -c/nf --start #{TIME[:start][:eng]} " \
             "--end #{TIME[:end][:eng]} -t token -d 'some description' " \
             '-l info -E test.wavefront.com -n test_ev')
      expect(o.status).to eq(0)
      expect(o.stderr).to be_empty
      expect(o.stdout_a[-3]).to eq('PUT https://test.wavefront.com/api/events/')
      expect(o.stdout_a[-2]).to have_element([:h, Socket.gethostname])
      expect(o.stdout_a[-2]).to have_element([:s, TIME[:start][:ms]])
      expect(o.stdout_a[-2]).to have_element([:e, TIME[:end][:ms]])
      expect(o.stdout_a[-2]).to have_element([:l, 'info'])
      expect(o.stdout_a[-2]).to have_element([:c, false])
      expect(o.stdout_a[-2]).to have_element([:d, 'some description'])
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose noop unbounded event with CLI and file options' do
      o = wf("event create -c #{CF} -P other -s #{TIME[:start][:eng]} " \
             "-t token -H i-123456,i-abcdef -d 'some description' -n test_ev")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq(
        'PUT https://other.wavefront.com/api/events/')
      expect(o.stdout_a[-2]).to have_element([:h, 'i-123456'])
      expect(o.stdout_a[-2]).to have_element([:h, 'i-abcdef'])
      expect(o.stdout_a[-2]).to have_element([:s, TIME[:start][:ms]])
      expect(o.stdout_a[-2]).not_to match(/&e=/)
      expect(o.stdout_a[-2]).to have_element([:c, false])
      expect(o.stdout_a[-2]).to have_element([:d, 'some description'])
    end

    it 'performs a verbose noop on an instantaneous event with CLI and ' \
       'file options' do
      o = wf("event create -c #{CF} -i -H i-123456 -d 'some description' " \
             '-l smoke -E test.wavefront.com -n test_ev')
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq('PUT https://test.wavefront.com/api/events/')
      expect(o.stdout_a[-2]).to have_element([:h, 'i-123456'])
      expect(o.stdout_a[-2]).not_to match(/&s=/)
      expect(o.stdout_a[-2]).not_to match(/&e=/)
      expect(o.stdout_a[-2]).to have_element([:c, 'true'])
      expect(o.stdout_a[-2]).to have_element([:l, 'smoke'])
      expect(o.stdout_a[-2]).to have_element([:d, 'some description'])
      expect(o.stdout_a[-1]).to eq(
        "HEADERS {:\"X-AUTH-TOKEN\"=>\"#{DEF_TOKEN}\"}")
    end
  end

  describe 'close subcommand' do
    it 'refuses to close an unknown event' do
      o = wf("event close -c #{CF} -t token -n unknown_event")
      expect(o.stderr).to eq(
        "event query failed. No event 'unknown_event' to close.")
      expect(o.status).to eq(1)
      expect(o.stdout).to be_empty
    end

    it 'performs a verbose noop with default options' do
      o = wf("event close -c/nf -t token -n test_ev #{TIME[:start][:ms]}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq(
        'PUT https://metrics.wavefront.com/api/events/close')
      expect(o.stdout_a[-2]).to have_element([:s, TIME[:start][:ms]])
      expect(o.stdout_a[-2]).to have_element([:n, 'test_ev'])
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose noop with CLI and file options' do
      o = wf("event close -P other -c #{CF} -t token -n test_ev " \
             "#{TIME[:start][:ms]}")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq(
        'PUT https://other.wavefront.com/api/events/close')
      expect(o.stdout_a[-2]).to have_element([:s, TIME[:start][:ms]])
      expect(o.stdout_a[-2]).to have_element([:n, 'test_ev'])
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end

    it 'performs a verbose noop with CLI options' do
      o = wf("event close -c/nf -E cli.wavefront.com -t token -n test_ev " +
             TIME[:start][:ms].to_s)
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-3]).to eq(
        'PUT https://cli.wavefront.com/api/events/close')
      expect(o.stdout_a[-2]).to have_element([:s, TIME[:start][:ms]])
      expect(o.stdout_a[-2]).to have_element([:n, 'test_ev'])
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end
  end

  describe 'delete subcommand' do
    it 'performs a verbose noop with default options' do
      o = wf("event delete -c/nf -t token -n #{TIME[:start][:ms]} test_ev")
      expect(o.stderr).to be_empty
      expect(o.status).to eq(0)
      expect(o.stdout_a[-2]).to eq('DELETE https://metrics.wavefront.com/' \
                                   "api/events/#{TIME[:start][:ms]}/test_ev")
      expect(o.stdout_a[-1]).to eq('HEADERS {:"X-AUTH-TOKEN"=>"token"}')
    end
  end
end

describe 'ts mode' do
  it 'fails with no granularity and default options' do
    o = wf('ts -t token -c/nf "ts(dev.cli.test)"')
    expect(o.status).to eq(1)
    expect(o.stdout).to match(
      /^config file.*not found. Taking options from command-line./)
    expect(o.stderr).to start_with(
      'ts query failed. You must specify a granularity')
  end

  it 'fails with no token if there is no token' do
    o = wf('ts -c/nf -E metrics.wavefront.com "ts(dev.cli.test)"')
    expect(o.status).to eq(1)
    expect(o.stderr).to eq('ts query failed. Please supply an API token.')
    expect(o.stdout).to eq(
      "config file '/nf' not found. Taking options from command-line.")
  end

  it 'performs a verbose noop with default options' do
    o = wf('ts -c/nf -t token -Sn "ts(dev.cli.test)"')
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq('GET https://metrics.wavefront.com/chart/api')
    q = raw(o.stdout_a.last)
    expect(q['X-AUTH-TOKEN']).to eq('token')
    expect(q[:params][:g]).to eq('s')
    expect(q[:params][:q]).to eq('ts(dev.cli.test)')
  end

  it 'performs a verbose noop with a CLI endpoint' do
    o = wf('ts -c/nf -t token -Sn -E test.wavefront.com "ts(dev.cli.test)"')
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq('GET https://test.wavefront.com/chart/api')
    q = raw(o.stdout_a.last)
    expect(q['X-AUTH-TOKEN']).to eq('token')
    expect(q[:params][:g]).to eq('s')
    expect(q[:params][:q]).to eq('ts(dev.cli.test)')
  end

  it 'performs a verbose noop with default config file options' do
    o = wf("ts -c #{CF} -Hn 'ts(dev.cli.test)'")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq('GET https://default.wavefront.com/chart/api')
    q = raw(o.stdout_a.last)
    expect(q['X-AUTH-TOKEN']).to eq(DEF_TOKEN)
    expect(q[:params][:g]).to eq('h')
    expect(q[:params][:q]).to eq('ts(dev.cli.test)')
  end

  it 'performs a verbose noop with config file and CLI options' do
    o = wf("ts -c #{CF} -P other -mn -E cli.wavefront.com 'ts(dev.cli.test)'")
    expect(o.status).to eq(0)
    expect(o.stderr).to be_empty
    expect(o.stdout_a[-2]).to eq('GET https://cli.wavefront.com/chart/api')
    q = raw(o.stdout_a.last)
    expect(q['X-AUTH-TOKEN']).to eq(OTHER_TOKEN)
    expect(q[:params][:g]).to eq('m')
    expect(q[:params][:q]).to eq('ts(dev.cli.test)')
  end
end
=end
