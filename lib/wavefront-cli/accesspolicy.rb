# frozen_string_literal: true

require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'accesspolicy' API.
  #
  class AccessPolicy < WavefrontCli::Base
    def do_describe
      wf.describe
    end
  end
end
