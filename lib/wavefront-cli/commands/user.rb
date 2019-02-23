require_relative 'base'

# Define the user command.
#
class WavefrontCommandUser < WavefrontCommandBase
  def description
    'view and manage Wavefront users'
  end

  # delete uses a different string because it accepts multiples.
  # Adding ellipsis to <id> causes everything else to expect an
  # array.
  #
  def _commands
    ["list #{CMN} [-l] [-O fields]",
     "describe #{CMN} [-f format] <id>",
     "create #{CMN} [-e] [-m permission...] [-g group...] [-f format] <id>",
     "invite #{CMN} [-m permission...] [-g group...] [-f format] <id>",
     "update #{CMN} <key=value> <id>",
     "delete #{CMN} <user>...",
     "import #{CMN} <file>",
     "groups #{CMN} <id>",
     "join #{CMN} <id> <group>...",
     "leave #{CMN} <id> <group>...",
     "grant #{CMN} <privilege> to <id>",
     "revoke #{CMN} <privilege> from <id>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long                list users in detail',
     '-o, --offset=n            start from nth user',
     '-L, --limit=COUNT         number of users to list',
     '-O, --fields=F1,F2,...    only show given fields',
     '-e, --email               send e-mail to user on account creation',
     '-m, --permission=STRING   give user this permission',
     '-g, --group=STRING        add user to this user group',
     '-f, --format=STRING       output format']
  end

  def postscript
    'If your account does not have RBAC enabled, you must grant user ' \
    "permissions with '-m'. For a list of permissions, see " \
    "'wf usergroup --help'.".fold(TW, 0)
  end
end
