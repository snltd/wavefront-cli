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
     "create #{CMN} [-p permission...] <name>",
     "delete #{CMN} <id>",
     "import #{CMN} [-u] <file>",
     "update #{CMN} <key=value> <id>",
     "users #{CMN} <id>",
     "permissions #{CMN} <id>",
     "add user #{CMN} <id> <user>...",
     "remove user #{CMN} <id> <user>...",
     "grant #{CMN} <permission> to <id>",
     "revoke #{CMN} <permission> from <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     '-p, --permission=STRING  Wavefront permission']
  end

  def postscript
    "'wf settings list permissions' will give you a list of all " \
    'currently supported permissions.'.fold(TW, 0)
  end
end
