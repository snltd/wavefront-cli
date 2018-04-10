require_relative 'base'

module WavefrontOutput
  #
  # Display as YAML
  #
  class Yaml < Base
    # We don't want the YAML keys to be symbols, so we load it as
    # JSON and turn *that* into YAML.
    #
    def run
      puts JSON.parse(resp.to_json).to_yaml
    end
  end
end