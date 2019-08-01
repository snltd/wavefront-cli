module WavefrontCliTest
  #
  # Mixin to test standard 'set' commands
  #
  module Set
    def test_set
      all_permutations do |p|
        stub_request(:get,
                     "https://#{p[:endpoint]}/api/v2/#{api_class}/#{id}")
          .with(headers: mk_headers(p[:token]))
          .to_return(status: 200,
                     body: { id: id, set_key => 'old_value' }.to_json,
                     headers: {})

        stub_request(:put,
                     "https://#{p[:endpoint]}/api/v2/#{api_class}/#{id}")
          .with(body: { id: id, set_key => 'new_value' },
                headers: mk_headers(p[:token]))
          .to_return(status: 200, body: '', headers: {})

        out, err = capture_io do
          wf.new("#{cmd_word} set #{set_key}=new_value #{id} " \
                "#{p[:cmdline]}".split)
        end

        assert_empty(err)
        assert_equal('No data.', out.strip)

        assert_requested(
          :get,
          "https://#{p[:endpoint]}/api/v2/#{api_class}/#{id}"
        )

        assert_requested(
          :put,
          "https://#{p[:endpoint]}/api/v2/#{api_class}/#{id}",
          body: { id: id, set_key.to_sym => 'new_value' }
        )

        assert_usage('set key=value')
        assert_cannot_noop("set key=value #{id}")
        assert_invalid_id("set key=value #{invalid_id}")
        assert_abort_on_missing_creds("set key=value #{id}")
      end
    end
  end
end
