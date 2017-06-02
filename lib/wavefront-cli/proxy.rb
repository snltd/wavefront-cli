require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'proxy' API.
  #
  class Proxy < WavefrontCli::Base
    #include WavefrontCli::Constants

    def do_list
      @response = :verbose
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      @response = :verbose
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
      wf_string?(options[:'<name>'])
      wf.rename(options[:'<id>'], options[:'<name>'])
    end

    def humanize_rename_output(data)
      puts "renamed #{data['id']} to '#{data['name']}'"
    end

    def extra_validation
      return unless options[:'<name>']
      begin
        wf_string?(options[:'<name>'])
      rescue Wavefront::Exception::InvalidString
        abort "'#{options[:'<name>']}' is not a valid proxy name."
      end
    end
  end
end
