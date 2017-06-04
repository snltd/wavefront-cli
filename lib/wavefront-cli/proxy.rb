require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'proxy' API.
  #
  class Proxy < WavefrontCli::Base

    def do_rename
      wf_string?(options[:'<name>'])
      wf.rename(options[:'<id>'], options[:'<name>'])
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
