# frozen_string_literal: true

require_relative 'base'

# Define the usergroup command.
#
class WavefrontCommandUsergroup < WavefrontCommandBase
  def thing
    'user group'
  end

  def description
    "view and manage Wavefront #{things}"
  end

  def sdk_class
    'UserGroup'
  end

  def sdk_file
    'usergroup'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "create #{CMN} [-r role_id...] <name>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "set #{CMN} <key=value> <id>",
     "add to #{CMN} <id> <user>...",
     "remove from #{CMN} <id> <user>...",
     "users #{CMN} <id>",
     "add role #{CMN} <id> <role>...",
     "remove role #{CMN} <id> <role>...",
     "roles #{CMN} <id>",
     "permissions #{CMN} <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}",
     '-r, --role-id=STRING     Wavefront role ID']
  end
end
