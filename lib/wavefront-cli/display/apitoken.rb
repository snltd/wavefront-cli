# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for API token commands
  #
  class ApiToken < Base
    def do_list_brief
      multicolumn(:tokenID, :tokenName)
    end

    def do_create
      puts data.last[:tokenID]
    end
  end
end
