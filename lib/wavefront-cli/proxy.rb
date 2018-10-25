require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'proxy' API.
  #
  class Proxy < WavefrontCli::Base
    def no_api_response
      %w[do_versions]
    end

    def do_rename
      wf_string?(options[:'<name>'])
      wf.rename(options[:'<id>'], options[:'<name>'])
    end

    def do_versions
      wf.list.response.items.map do |i|
        { id: i.id, version: i.version, name: i.name }
      end.sort_by { |p| p[:version] }.reverse
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
