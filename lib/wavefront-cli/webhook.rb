require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'webhook' API.
  #
  class Webhook < WavefrontCli::Base
    def do_list
      @response = :verbose
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
      wf.describe(options[:'<id>'])
    end

    def do_import
      raw = load_file(options[:'<file>'])

      begin
        prepped = import_to_create(raw)
      rescue => e
        puts e if options[:debug]
        raise 'could not parse input.'
      end

      wf.create(prepped)
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def import_to_create(raw)
      raw.delete_if { |k, _v| k == 'id' }
    end
  end
end
