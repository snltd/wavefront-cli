# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'derivedmetric' API.
  #
  class ApiToken < WavefrontCli::Base
    def validator_exception
      Wavefront::Exception::InvalidApiTokenId
    end

    def do_list
      wf.list
    end

    def do_create
      wf.create
    end

    def do_rename
      wf.rename(options[:'<id>'], options[:'<name>'])
    end
  end
end
