require_relative 'base'

# Define the usergroup command.
#
class WavefrontCommandUsergroup < WavefrontCommandBase
  def description
    'view and manage Wavefront user groups'
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
     "import #{CMN} <file>",
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
     '-l, --long                list users in detail',
     '-o, --offset=n            start from nth user group',
     '-L, --limit=COUNT         number of user group to list',
     '-O, --fields=F1,F2,...    only show given fields',
     '-p, --permission=STRING   Wavefront permission',
     '-u, --user=STRING         user name',
     '-f, --format=STRING       output format']
  end

  def postscript
    'Valid permissions at the time of writing are: agent_management, ' \
    'alerts_management, dashboard_management, embedded_charts, ' \
    'events_management, external_links_management, host_tag_management, ' \
    'metrics_management, and user_management. Check the API docs for ' \
    'an up-to-date list.'.fold(TW, 0)
  end
end
