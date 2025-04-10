# frozen_string_literal: true

require 'spy'
require 'webmock/minitest'
require_relative '../constants'

# rubocop:disable Metrics/ModuleLength
module Minitest
  #
  # Custom assertions to facilitate CLI command testing
  #
  module Assertions
    def assert_gets(api_path, headers, response, &block)
      stub = stub_request(:get, api_path)
             .with(headers: headers)
             .to_return(body: response, status: 200)
      yield block
      assert_requested(stub)
    end

    def assert_gets_with_params(api_path, params, headers, response, &block)
      stub = stub_request(:get, api_path)
             .with(query: hash_including(params),
                   headers: headers)
             .to_return(body: response, status: 200)
      yield block
      assert_requested(stub)
    end

    def assert_posts(api_path, headers, payload, response, &block)
      stub = stub_request(:post, api_path)
             .with(body: payload, headers: headers)
             .to_return(body: response, status: 200)
      yield block
      assert_requested(stub)
    end

    def assert_puts(api_path, headers, _payload, response, &block)
      stub = stub_request(:put, api_path)
             .with(headers: headers)
             .to_return(body: response, status: 200)
      yield block
      assert_requested(stub)
    end

    def assert_deletes(api_path, headers, response, &block)
      stub = stub_request(:delete, api_path)
             .with(headers: headers)
             .to_return(body: response, status: 200)
      yield block
      assert_requested(stub)
    end

    # Don't bother testing permutations for this
    #
    def assert_invalid_id(command)
      out, err = capture_io do
        assert_raises(SystemExit) { wf.new("#{cmd_word} #{command}".split) }
      end

      assert_empty(out)
      assert_match(/is not a valid [\w ]+ ID.$/, err)
    end

    def assert_usage(command)
      out, err = capture_io do
        assert_raises(SystemExit) { wf.new("#{cmd_word} #{command}".split) }
      end

      assert_empty(out)
      assert_match(/^Usage:\n  wf #{cmd_word}/, err)
    end

    def assert_abort_on_missing_creds(command)
      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new("#{cmd_word} #{command} --config /nofile".split)
        end
      end

      assert_empty(out)
      assert_equal("Configuration file '/nofile' not found.\n", err)
    end

    def assert_exits_with(message, command)
      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new("#{cmd_word} #{command} --config #{CF}".split)
        end
      end

      assert_empty(out)
      assert_equal(message, err.strip)
    end

    def assert_cannot_noop(command)
      out, err = capture_io do
        assert_raises(SystemExit) do
          wf.new("#{cmd_word} #{command} --noop --config #{CF}".split)
        end
      end

      assert_empty(out)
      assert_equal('Multiple API call operations cannot be ' \
                   "performed as no-ops.\n", err)
    end

    def assert_repeated_output(msg, &)
      begin
        out, err = capture_io(&)
      rescue SystemExit => e
        puts e.backtrace
        p e
      end

      assert_empty(err)
      out.each_line { |l| assert_equal(msg, l.rstrip) }
    end

    def assert_cmd_gets(command, api_path, response = dummy_response)
      all_permutations do |p|
        assert_gets(full_uri(p[:endpoint], api_path),
                    mk_headers(p[:token]), response) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end
      end
    end

    def full_uri(host, api_path)
      if api_path.is_a?(Regexp)
        %r{^https://#{host}#{api_path.source}$}
      else
        "https://#{host}#{api_path}"
      end
    end

    def assert_cmd_gets_with_params(command, api_path, params,
                                    response = dummy_response)
      all_permutations do |p|
        assert_gets_with_params("https://#{p[:endpoint]}#{api_path}",
                                params,
                                mk_headers(p[:token]),
                                response) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end
      end
    end

    def assert_cmd_posts(command, api_path, payload = 'null',
                         response = nil, extra_headers = {})
      response ||= dummy_response
      all_permutations do |p|
        assert_posts("https://#{p[:endpoint]}#{api_path}",
                     mk_headers(p[:token], extra_headers),
                     payload,
                     response) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end
      end
    end

    def assert_cmd_puts(command, api_path, payload, response = dummy_response)
      all_permutations do |p|
        assert_puts("https://#{p[:endpoint]}#{api_path}",
                    mk_headers(p[:token]), payload, response) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end
      end
    end

    def assert_cmd_deletes(command, api_path, response = dummy_response)
      all_permutations do |p|
        assert_deletes("https://#{p[:endpoint]}#{api_path}",
                       mk_headers(p[:token]), response) do
          wf.new("#{cmd_word} #{command} #{p[:cmdline]}".split)
        end
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

    # Run tests with all available permutations, unless the single_perm class
    # variable is set. This lets us run tests faster by running fewer (but
    # still a good random selection) and lets us run tests which must only be
    # run once, like tests which pop stuff off the event stack.
    #
    def all_permutations
      perms = permutations
      perms = perms.shuffle.take(1) if @single_perm || ENV['FAST_TESTS']

      perms.each do |p|
        yield(p)
        WebMock.reset!
      end
    end

    # Helper to avoid dealing with our display methods
    #
    def quietly
      d = Spy.on_instance_method(cmd_class, :display)
      yield
      assert d.has_been_called?
      d.unhook
    end

    private

    def mk_headers(token = nil, extra_headers = {})
      { Accept: /.*/,
        'Accept-Encoding': /.*/,
        Authorization: "Bearer #{token || '0123456789-ABCDEF'}",
        'User-Agent': "wavefront-cli-#{WF_CLI_VERSION}" }.merge(extra_headers)
    end

    # Every command we simulate running is done under the following
    # permutations
    #
    def permutations
      [{ cmdline: "-t #{TOKEN} -E #{ENDPOINT}",
         token: TOKEN,
         endpoint: ENDPOINT },

       { cmdline: "-c #{CF}",
         token: CF_VAL['default']['token'],
         endpoint: CF_VAL['default']['endpoint'] },

       { cmdline: "-c #{CF} -P other",
         token: CF_VAL['other']['token'],
         endpoint: CF_VAL['other']['endpoint'] },

       { cmdline: "-c #{CF} --profile other -t #{TOKEN}",
         token: TOKEN,
         endpoint: CF_VAL['other']['endpoint'] },

       { cmdline: "--config #{CF} -E #{ENDPOINT}",
         token: CF_VAL['default']['token'],
         endpoint: ENDPOINT }]
    end

    # Drop this into bodies when you need to check a non-specific
    # timestamp is there
    #
    def a_timestamp
      proc { |t| t.to_s =~ /^\d{10}$/ }
    end

    def a_ms_timestamp
      proc { |t| t.to_s =~ /^\d{13}$/ }
    end
  end
end
# rubocop:enable Metrics/ModuleLength
