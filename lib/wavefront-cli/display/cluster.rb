# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for config commands.
  #
  class Cluster < Base
    def do_location
      puts data
    end
    alias do_profiles do_location
    alias do_show do_location
    alias do_envvars do_location

    def do_about
      long_output
    end
  end
end
