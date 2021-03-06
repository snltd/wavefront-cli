# frozen_string_literal: true

module WavefrontCliTest
  #
  # Mixin to test standard 'dump' commands
  #
  module Dump
    def test_dump_human
      assert_exits_with(
        "Dump format must be 'json' or 'yaml'. (Tried 'human')",
        'dump --format=human'
      )
    end

    def test_dump_json
      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_gets('dump --format=json',
                          "/api/v2/#{api_path}?limit=999&offset=0")
        end
        Spy.teardown
      end

      assert_cannot_noop('dump --format=json')
      assert_empty(err)
      assert_equal([].to_s, out.rstrip)
    end

    def test_dump_yaml
      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_gets('dump --format=yaml',
                          "/api/v2/#{api_path}?limit=999&offset=0")
        end
        Spy.teardown
      end

      assert_cannot_noop('dump --format=yaml')
      assert_empty(err)
      assert_equal('--- []', out.rstrip)
    end
  end
end
