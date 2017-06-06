require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'source' API.
  #
  class Source < WavefrontCli::Base
    def do_description_set
      wf.update(options[:'<id>'], description: options[:'<description>'])
    end

    def do_description_clear
      abort 'This command is currently unsupported.'
    end
  end
end
