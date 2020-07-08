# frozen_string_literal: true

require_relative 'base'

# Define the 'role' command.
#
class WavefrontCommandRole < WavefrontCommandBase
  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "create #{CMN} [-d description] [-p permission...] <name>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "set #{CMN} <key=value> <id>",
     "accounts #{CMN} <id>",
     "groups #{CMN} <id>",
     "permissions #{CMN} <id>",
     "give #{CMN} <id> to <member>...",
     "take #{CMN} <id> from <member>...",
     "grant #{CMN} <permission> to <id>",
     "revoke #{CMN} <permission> from <id>",
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
     "-d, --description=STRING description of #{thing}",
     '-p, --permission=STRING  Wavefront permission']
  end

  def postscript
    "A role 'member' can be an account ID or a usergroup ID. 'wf settings " \
    "list permissions' will give you a list of all currently supported " \
    'permissions.'.fold(TW, 0)
  end
end
