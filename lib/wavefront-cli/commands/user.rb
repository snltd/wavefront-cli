require_relative 'base'

# Define the user command.
#
class WavefrontCommandUser < WavefrontCommandBase
  def description
    "view and manage Wavefront #{things}"
  end

  # delete uses a different string because it accepts multiples.
  # Adding ellipsis to <id> causes everything else to expect an
  # array.
  #
  def _commands
    ["list #{CMN} [-l] [-O fields]",
     "describe #{CMN} <id>",
     "create #{CMN} [-e] [-m permission...] [-g group...] <id>",
     "invite #{CMN} [-m permission...] [-g group...] <id>",
     "modify #{CMN} <key=value> <id>",
     "delete #{CMN} <user>...",
     "import #{CMN} [-u] <file>",
     "groups #{CMN} <id>",
     "join #{CMN} <id> <group>...",
     "leave #{CMN} <id> <group>...",
     "grant #{CMN} <privilege> to <id>",
     "revoke #{CMN} <privilege> from <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-e, --email              send e-mail to #{thing} on account creation",
     "-m, --permission=STRING  give #{thing} this permission",
     "-g, --group=STRING       add #{thing} to this user group"]
  end

  def postscript
    'If your account does not have RBAC enabled, you must grant user ' \
    "permissions with '-m'. For a list of permissions, see " \
    "'wf usergroup --help'.".fold(TW, 0)
  end
end
