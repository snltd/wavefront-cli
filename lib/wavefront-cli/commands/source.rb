# frozen_string_literal: true

require_relative 'base'

# Define the source command.
#
class WavefrontCommandSource < WavefrontCommandBase
  def description
    'view and manage source tags and descriptions'
  end

  def _commands
    ["list #{CMN} [-l] [-O fields] [-o cursor] [-L limit] [-a]",
     "describe #{CMN} <id>",
     "description set  #{CMN} <id> <description>",
     "description clear  #{CMN} <id>",
     "clear  #{CMN} <id>",
     "search #{CMN} [-al] [-o cursor] [-L limit] <condition>...",
     tag_commands]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-o, --cursor=SOURCE      start list given #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list",
     "-a, --all                list all #{things}, including cluster"]
  end
end
