# frozen_string_literal: true

require_relative 'base'

# Define the Alert command
#
class WavefrontCommandAlert < WavefrontCommandBase
  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "firing #{CMN} [-o offset] [-L limit]",
     "affected #{CMN} hosts [<id>]",
     "snoozed #{CMN} [-o offset] [-L limit]",
     "describe #{CMN} [-v version] <id>",
     "delete #{CMN} <id>",
     "clone #{CMN} [-v version] <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "latest #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "snooze #{CMN} [-T time] <id>",
     "set #{CMN} <key=value> <id>",
     "unsnooze #{CMN} <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>...",
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
     "-U, --upsert             import new or update existing #{thing}",
     '-T, --time=SECONDS       how long to snooze (default 3600)',
     "-b, --brief              do not show #{thing} names"]
  end
end
