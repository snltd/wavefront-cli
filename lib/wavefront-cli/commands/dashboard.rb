require_relative 'base'

# Define the dashboard command.
#
class WavefrontCommandDashboard < WavefrontCommandBase
  def description
    'view and manage dashboards'
  end

  def _commands
    ["list #{CMN} [-alN] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} [-v version] <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     "queries #{CMN} [-b] [<id>]",
     "fav #{CMN} <id>",
     "unfav #{CMN} <id>",
     acl_commands,
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long               list dashboards in detail',
     '-a, --all                list all dashboards',
     '-o, --offset=n           start list from nth dashboard or revision',
     '-O, --fields=F1,F2,...   only show given fields',
     '-L, --limit=COUNT        number of dashboards or revisions to list',
     '-v, --version=INTEGER    version of dashboard',
     '-b, --brief              do not show dashboard names',
     '-N, --no-system          do not show system-owned dashboards',
     '-f, --format=STRING      output format']
  end
end
