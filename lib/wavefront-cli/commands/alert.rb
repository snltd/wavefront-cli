require_relative 'base'

# Define the Alert command
#
class WavefrontCommandAlert < WavefrontCommandBase
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
     "import #{CMN} [-u] <file>",
     "snooze #{CMN} [-T time] <id>",
     "set #{CMN} <key=value> <id>",
     "unsnooze #{CMN} <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     tag_commands,
     "currently #{CMN} <state>",
     "queries #{CMN} [-b] [<id>]",
     "install #{CMN} <id>",
     "uninstall #{CMN} <id>",
     acl_commands,
     "summary #{CMN} [-a]"]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-v, --version=INTEGER    describe only this version of #{thing}",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     '-T, --time=SECONDS       how long to snooze (default 3600)',
     "-b, --brief              do not show #{thing} names"]
  end
end
