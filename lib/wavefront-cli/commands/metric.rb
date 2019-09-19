# frozen_string_literal: true

require_relative 'base'

# Define the metric command.
#
class WavefrontCommandMetric < WavefrontCommandBase
  def description
    "get #{thing} details"
  end

  def _commands
    ["describe #{CMN} [-o offset] [-g glob...] <metric>"]
  end

  def _options
    [common_options,
     '-o, --offset=STRING      value to start from if results > 1000',
     '-g, --glob=STRING        return sources matching this pattern']
  end
end
