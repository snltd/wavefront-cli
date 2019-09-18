# frozen_string_literal: true

require_relative 'base'

module WavefrontOutput
  #
  # Display as JSON
  #
  class Json < Base
    def _run
      resp.to_json
    end

    def allow_items_only?
      true
    end
  end
end
