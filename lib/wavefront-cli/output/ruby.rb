# frozen_string_literal: true

require_relative 'base'

module WavefrontOutput
  #
  # Display as a raw Ruby object
  #
  class Ruby < Base
    def run
      p _run
    end

    def _run
      resp
    end

    def allow_items_only?
      true
    end
  end
end
