require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'agent' API.
  #
  class Agent < WavefrontCli::Base
    include WavefrontCli::Constants

    def do_list
      @verbose_response = true
      wf.list(options[:start] || 0, options[:limit] || 100)
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def humanize_undelete_output(data)
      puts "undeleted agent #{data['id']}: #{data['name']}."
    end

    def do_rename
      wf.rename(options[:'<id>'], options[:'<name>'])
    end

    def humanize_rename_output(data)
      puts "renamed #{data['id']} to '#{data['name']}'"
    end
  end
end
