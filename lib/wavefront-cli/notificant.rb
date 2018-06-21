require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'notificant' API.
  #
  class Notificant < WavefrontCli::Base
    def do_test
      wf.test(options[:'<id>'])
    end
  end
end
