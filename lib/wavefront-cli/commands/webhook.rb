# frozen_string_literal: true

require_relative 'base'

# Define the webhook command.
#
class WavefrontCommandWebhook < WavefrontCommandBase
  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start list from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list",
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}"]
  end
end
