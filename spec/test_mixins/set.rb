# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'set' commands
  #
  module Set
    def test_set
      all_permutations do |p|
        get_stub = get_stub(p)
        put_stub = put_stub(p)
        out, err = capture_io { run_command(p) }
        assert_empty(err)
        assert_equal('No data.', out.strip)
        assert_requested(get_stub)
        assert_requested(put_stub)
        assert_usage('set key=value')
        assert_cannot_noop("set key=value #{id}")
        assert_invalid_id("set key=value #{invalid_id}")
        assert_abort_on_missing_creds("set key=value #{id}")
      end
    end

    def run_command(perm)
      wf.new("#{cmd_word} set #{set_key}=new_value #{id} " \
            "#{perm[:cmdline]}".split)
    rescue SystemExit => e
      p e
    end

    def get_stub(perm)
      stub_request(:get,
                   "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(headers: mk_headers(perm[:token]))
        .to_return(status: 200,
                   body: { id: id, set_key => 'old_value' }.to_json,
                   headers: {})
    end

    def put_stub(perm)
      stub_request(:put, "https://#{perm[:endpoint]}/api/v2/#{api_class}/#{id}")
        .with(body: { id: id, set_key => 'new_value' },
              headers: mk_headers(perm[:token]))
        .to_return(status: 200, body: '', headers: {})
    end
  end
end
