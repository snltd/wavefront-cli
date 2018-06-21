require_relative 'base'

# Define the Alert command
#
class WavefrontCommandAlert < WavefrontCommandBase
  def description
    'view and manage alerts'
  end
  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "firing #{CMN} [-o offset] [-L limit]",
     "snoozed #{CMN} [-o offset] [-L limit]",
     "describe #{CMN} [-f format] [-v version] <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-f format] [-o offset] [-L limit] <id>",
     "import #{CMN} <file>",
     "snooze #{CMN} [-T time] <id>",
     "update #{CMN} <key=value> <id>",
     "unsnooze #{CMN} <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>...",
     "tags #{CMN} [-f format] <id>",
     "tag set #{CMN} <id> <tag>...",
     "tag clear #{CMN} <id>",
     "tag add #{CMN} <id> <tag>",
     "tag delete #{CMN} <id> <tag>",
     "summary #{CMN} [-a]"]
  end

  def _options
    [common_options,
     '-l, --long               list alerts in detail',
     '-a, --all                list all alerts',
     '-v, --version=INTEGER    describe only this version of alert',
     '-o, --offset=n           start from nth alert',
     '-L, --limit=COUNT        number of alerts to list',
     '-T, --time=SECONDS       how long to snooze (default 3600)',
     '-f, --format=STRING      output format']
  end
end
