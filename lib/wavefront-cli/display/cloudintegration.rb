require_relative './base'

module WavefrontDisplay

  # Format human-readable output for cloud integrations.
  #
  class CloudIntegration < Base
    def do_import
      puts 'Imported cloud integration.'
      long_output
    end

    def do_list_brief
      terse_output(:id, :service)
    end

    def do_delete
      puts "Deleted cloud integration '#{options[:'<id>']}'."
    end

    def do_undelete
      puts "Uneleted cloud integration '#{options[:'<id>']}'."
    end
  end
end
