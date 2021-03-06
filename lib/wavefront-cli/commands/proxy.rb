# frozen_string_literal: true

require_relative 'base'

# Define the proxy command.
#
class WavefrontCommandProxy < WavefrontCommandBase
  def things
    'proxies'
  end

  def _commands
    ["list #{CMN} [-laA] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "rename #{CMN} <id> <name>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>...",
     "shutdown #{CMN} <id>",
     "versions #{CMN}"]
  end

  def _options
    [common_options,
     "-l, --long                list #{things} in detail",
     "-a, --all                 list all #{things}",
     "-A, --active              only show active #{things}",
     "-o, --offset=n            start from nth #{thing}",
     '-O, --fields=F1,F2,...    only show given fields',
     "-L, --limit=COUNT         number of #{things} to list"]
  end
end
