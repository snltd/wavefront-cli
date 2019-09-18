# frozen_string_literal: true

require_relative 'base'

# Define the settings command.
#
class WavefrontCommandSettings < WavefrontCommandBase
  def thing
    'system preference'
  end

  def _commands
    ["list permissions #{CMN} [-l] [-O fields]",
     "show preferences #{CMN} [-l] [-O fields]",
     "set #{CMN} <key=value>...",
     "default usergroups #{CMN} [-l] [-O fields]"]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     '-O, --fields=F1,F2,...  only show given fields']
  end
end
