require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'agent' API.
  #
  class Agent < WavefrontCli::Base
    include WavefrontCli::Constants

    def do_list
      wf.list(options[:start] || 0, options[:limit] || 100)
    end

    def humanize_list_output(data)
      puts "Found #{data['items'].size} agents\n\n"

      data['items'].each do |agent|
        agent.each { |k, v| puts format("%-#{key_width(agent)}s%s", k, v) }
        puts
      end
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    def humanize_describe_output(data)
      data.each { |k, v| puts format("%-#{key_width(data)}s%s", k, v) }
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
