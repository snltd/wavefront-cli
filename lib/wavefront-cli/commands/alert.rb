require_relative 'base'

# Define the Alert command
#
class WavefrontCommandAlert < WavefrontCommandBase
  def description
    'view and manage alerts'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "firing #{CMN} [-o offset] [-L limit]",
     "snoozed #{CMN} [-o offset] [-L limit]",
     "describe #{CMN} [-v version] <id>",
     "delete #{CMN} <id>",
     "clone #{CMN} [-v version] <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "clone #{CMN} [-v version] <id>",
     "latest #{CMN} <id>",
     "import #{CMN} <file>",
     "snooze #{CMN} [-T time] <id>",
     "update #{CMN} <key=value> <id>",
     "unsnooze #{CMN} <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     "tags #{CMN} <id>",
     "tag set #{CMN} <id> <tag>...",
     "tag clear #{CMN} <id>",
     "tag add #{CMN} <id> <tag>",
     "tag delete #{CMN} <id> <tag>",
     "currently #{CMN} <state>",
     "queries #{CMN} [-b] [<id>]",
     "install #{CMN} <id>",
     "uninstall #{CMN} <id>",
     acl_commands,
     "summary #{CMN} [-a]"]
  end

  def _options
    [common_options,
     '-l, --long               list alerts in detail',
     '-a, --all                list all alerts',
     '-v, --version=INTEGER    describe only this version of alert',
     '-o, --offset=n           start from nth alert',
     '-L, --limit=COUNT        number of alerts to list',
     '-O, --fields=F1,F2,...   only show given fields',
     '-T, --time=SECONDS       how long to snooze (default 3600)',
     '-b, --brief              do not show alert names',
     '-f, --format=STRING      output format']
  end
end
