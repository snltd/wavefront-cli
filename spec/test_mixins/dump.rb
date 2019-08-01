module WavefrontCliTest
  #
  # Mixin to test standard 'dump' commands
  #
  module Dump
    def test_dump_human
      assert_exits_with('dump --format=human',
                        "Dump format must be 'json' or 'yaml'. " \
                        "(Tried 'human')")
    end

    def test_dump_json
      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_gets('dump --format=json',
                          "/api/v2/#{api_class}?limit=999&offset=0")
        end
        Spy.teardown
      end

      assert_equal([].to_s, out.rstrip)
      assert_empty(err)
    end

    def test_dump_yaml
      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_gets('dump --format=yaml',
                          "/api/v2/#{api_class}?limit=999&offset=0")
        end
        Spy.teardown
      end

      assert_equal('--- []', out.rstrip)
      assert_empty(err)
    end
  end
end
