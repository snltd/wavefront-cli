# frozen_string_literal: true

require_relative 'base'

# Define the metric command.
#
class WavefrontCommandMetric < WavefrontCommandBase
  def description
    "get #{thing} details"
  end

  def _commands
    ["describe #{CMN} [-o offset] [-g glob...] <metric>",
     "list under #{CMN} <metric>",
     "list all #{CMN}"]
  end

  def _options
    [common_options,
     '-o, --offset=STRING      value to start from if results > 1000',
     '-g, --glob=STRING        return sources matching this pattern']
  end

  def postscript
    "\nNOTE: the 'list under' and 'list all' sub-commands use the unoffical " \
      "'chart' endpoint, which is not guaranteed to remain stable.\n\n" \
      'Both commands have to make a lot of API calls, and may take a ' \
      'very long time to run.'.cmd_fold(TW, 0)
  end
end
