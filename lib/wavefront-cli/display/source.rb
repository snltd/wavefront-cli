require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for webhooks.
  #
  class Source < Base
    def do_list_brief
      terse_output(:id, :description)
    end
  end
end
