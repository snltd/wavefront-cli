# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for usage commands.
  #
  class Usage < Base
    def do_export_csv
      puts data[:message]
    end
  end
end
