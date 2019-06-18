require_relative 'base'

# Define the notificant command.
#
class WavefrontCommandNotificant < WavefrontCommandBase
  def thing
    'alert target'
  end

  def description
    "view and manage Wavefront #{things}"
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "import #{CMN} [-u] <file>",
     "delete #{CMN} <id>",
     "test #{CMN} <id>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list",
     "-u, --update             update an existing #{thing}"]
  end
end
