# frozen_string_literal: true

require_relative 'base'

# Define the metricspolicy command.
#
class WavefrontCommandMetricspolicy < WavefrontCommandBase
  def thing
    'metrics policy'
  end

  def things
    'metrics policies'
  end

  def sdk_class
    'MetricsPolicy'
  end

  def _commands
    ["describe #{CMN} [-v version]",
     "history #{CMN} [-o offset] [-L limit]",
     "revert #{CMN} <version>",
     "update #{CMN} <file>"]
  end

  def _options
    [common_options,
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} or revisions to list",
     "-v, --version=INTEGER    version of #{thing}"]
  end
end
