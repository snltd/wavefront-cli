require 'spy'
require 'webmock/minitest'
require_relative '../constants'

module Minitest
  #
  # Custom assertions to facilitate CLI command testing
  #
  module Assertions
    def assert_gets(api_path, headers, &block)
      stub_request(:get, api_path)
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:get, api_path, headers: headers)
      WebMock.reset!
    end

    def assert_posts(api_path, headers, payload, &block)
      stub_request(:post, api_path)
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:post, api_path, headers: headers)
      WebMock.reset!
    end

    def assert_puts(api_path, headers, payload, &block)
      stub_request(:put, api_path)
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:put, api_path, headers: headers)
      WebMock.reset!
    end

    def assert_deletes(api_path, headers, &block)
      stub_request(:delete, api_path)
        .with(headers: headers)
        .to_return(body: DUMMY_RESPONSE, status: 200)
      yield block
      assert_requested(:delete, api_path, headers: headers)
      WebMock.reset!
    end

    # Don't bother testing permutations for this
    #
    def assert_invalid_id(command)
      out, err = capture_io do
        assert_raises(SystemExit) { wf.new("#{cmd_word} #{command}".split) }
      end

      assert_match(/is not a valid \w+ ID.$/, err)
      assert_empty(out)
    end

    def assert_usage(command)
      out, err = capture_io do
        assert_raises(SystemExit) { wf.new("#{cmd_word} #{command}".split) }
      end

      assert_match(/^Usage:\n  wf #{cmd_word}/, err)
      assert_empty(out)
    end

    def assert_abort_on_missing_creds(command)
      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new("#{cmd_word} #{command} --config /nofile".split)
        end
      end

      assert_equal("Configuration file '/nofile' not found.\n", err)
      assert_empty(out)
    end

    def assert_cmd_gets(command, api_path)
      permutations.each do |p|
        d = Spy.on_instance_method(sdk_class, :display)

        assert_gets("https://#{p[:endpoint]}#{api_path}",
                    mk_headers(p[:token])) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end

        assert d.has_been_called?
        d.unhook
      end
    end

    def assert_cmd_posts(command, api_path, payload)
      permutations.each do |p|
        d = Spy.on_instance_method(sdk_class, :display)

        assert_posts("https://#{p[:endpoint]}#{api_path}",
                     mk_headers(p[:token]), payload) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end

        assert d.has_been_called?
        d.unhook
      end
    end

    def assert_cmd_puts(command, api_path, payload)
      permutations.each do |p|
        d = Spy.on_instance_method(sdk_class, :display)

        assert_puts("https://#{p[:endpoint]}#{api_path}",
                     mk_headers(p[:token]), payload) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end

        assert d.has_been_called?
        d.unhook
      end
    end

    def assert_cmd_deletes(command, api_path)
      permutations.each do |p|
        d = Spy.on_instance_method(sdk_class, :display)

        assert_deletes("https://#{p[:endpoint]}#{api_path}",
                       mk_headers(p[:token])) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end

        assert d.has_been_called?
        d.unhook
      end
    end

    def assert_noop(command, *expected)
      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new("#{cmd_word} #{command} -c #{CF} --noop".split)
        end
      end

      out.strip.split("\n").each.with_index do |l, i|
        assert_equal("SDK INFO: #{expected[i]}", l)
      end

      assert_empty(err)
    end

    private

    def mk_headers(token = nil)
      { 'Accept':          /.*/,
        'Accept-Encoding': /.*/,
        'Authorization':   'Bearer ' + token || '0123456789-ABCDEF',
        'User-Agent':      "wavefront-cli-#{WF_CLI_VERSION}" }
    end

    # Every command we simulate running is done under the following
    # permutations
    #
    def permutations
      [{ cmdline:  "-t #{TOKEN} -E #{ENDPOINT}",
         token:    TOKEN,
         endpoint: ENDPOINT },

       { cmdline:  "-c #{CF}",
         token:    CF_VAL['default']['token'],
         endpoint: CF_VAL['default']['endpoint'] },

       { cmdline:  "-c #{CF} -P other",
         token:    CF_VAL['other']['token'],
         endpoint: CF_VAL['other']['endpoint'] },

       { cmdline:  "-c #{CF} --profile other -t #{TOKEN}",
         token:    TOKEN,
         endpoint: CF_VAL['other']['endpoint'] },

       { cmdline:  "--config #{CF} -E #{ENDPOINT}",
         token:    CF_VAL['default']['token'],
         endpoint: ENDPOINT }]
    end
  end
end
