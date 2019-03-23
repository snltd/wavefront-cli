require_relative 'base'

# Define the settings command.
#
class WavefrontCommandSettings < WavefrontCommandBase
  def description
    'view and manage system preferences'
  end

  def _commands
    ["list permissions #{CMN} [-l] [-O fields]",
     "show preferences #{CMN} [-l] [-O fields]",
     "update #{CMN} <key=value>...",
     "default usergroups #{CMN} [-l] [-O fields]"]
  end

  def _options
    [common_options,
     '-l, --long              list derived metrics in detail',
     '-O, --fields=F1,F2,...  only show given fields']
  end
end
