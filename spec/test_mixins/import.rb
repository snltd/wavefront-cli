module WavefrontCliTest
  #
  # Mixin to test standard 'import' commands
  #
  module Import
    def test_import
      Spy.teardown

      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_posts("import #{import_file}",
                           "/api/v2/#{api_class}",
                           import_data)
          Spy.teardown
        end
      end

      assert_empty(err)
      assert_equal('IMPORTED', out.strip)

      assert_exits_with('import /no/such/file', 'File not found.')
      assert_usage('import')
      assert_abort_on_missing_creds("import #{import_file}")
    end

    def test_import_update
      Spy.teardown

      out, err = capture_io do
        assert_raises(SystemExit) do
          assert_cmd_puts("import -u #{update_file}",
                          "/api/v2/#{api_class}/1556812163465",
                          update_data)
          Spy.teardown
        end
      end

      assert_empty(err)
      assert_equal('1556812163465   IMPORTED', out.strip)

      assert_exits_with('import -u /no/such/file', 'File not found.')
      assert_usage('import -u')
      assert_abort_on_missing_creds("import -u #{import_file}")
    end

    def test_import_fields
      x = cmd_instance.import_to_create(cmd_instance.load_file(import_file))
      assert_instance_of(Hash, x)
      import_fields.each { |f| assert_includes(x.keys, f) }
      blocked_import_fields.each { |f| refute_includes(x.keys, f) }
    end

    private

    def import_file
      RES_DIR + 'imports' + "#{api_class}.json"
    end

    def update_file
      RES_DIR + 'updates' + "#{api_class}.json"
    end
  end
end
