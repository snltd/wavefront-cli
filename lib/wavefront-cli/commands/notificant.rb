require_relative 'base'

# Define the notificant command.
#
class WavefrontCommandNotificant < WavefrontCommandBase
  def description
    'view and manage Wavefront alert targets'
  end

  def _commands
    ["list #{CMN} [-al] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "import #{CMN} <file>",
     "delete #{CMN} <id>",
     "test #{CMN} <id>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long                list alert targets in detail',
     '-a, --all                 list all alert targets',
     '-o, --offset=n            start from nth alert target',
     '-f, --format=STRING       output format',
     '-L, --limit=COUNT         number of alert targets to list']
  end
end
