# frozen_string_literal: true

require_relative 'base'

module WavefrontOutput
  #
  # Display as YAML
  #
  class Yaml < Base
    # We don't want the YAML keys to be symbols, so we load it as
    # JSON and turn *that* into YAML.
    #
    def _run
      JSON.parse(resp.to_json).to_yaml
    end

    def allow_items_only?
      true
    end
  end
end
