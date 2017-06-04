require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
    def do_history
      wf.history(options[:'<id>'])
    end
  end
end
