# frozen_string_literal: true

require_relative 'base'

# Define the dashboard command.
#
class WavefrontCommandDashboard < WavefrontCommandBase
  def _commands
    ["list #{CMN} [-alN] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} [-v version] <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "set #{CMN} <key=value> <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>...",
     "queries #{CMN} [-b] [<id>]",
     "favs #{CMN}",
     "fav #{CMN} <id>",
     "unfav #{CMN} <id>",
     acl_commands,
     tag_commands]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start list from nth #{thing} or revision",
     "-L, --limit=COUNT        number of #{things} or revisions to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}",
     '-T, --time=SECONDS       how long to snooze (default 3600)',
     "-v, --version=INTEGER    version of #{thing}",
     "-b, --brief              do not show #{thing} names",
     "-N, --no-system          do not show system-owned #{things}"]
  end
end
