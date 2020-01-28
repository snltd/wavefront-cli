# frozen_string_literal: true

require_relative 'base'

# Define the usage command.
#
class WavefrontCommandUsage < WavefrontCommandBase
  def thing
    'usage report'
  end

  def _commands
    ["export csv #{CMN} [-s time] [-e time] "]
  end

  def _options
    [common_options,
     "-s, --start=TIME        time at which #{thing} begins " \
     '(defaults to 24h ago)',
     "-e, --end=TIME          time at which #{thing} ends"]
  end
end
