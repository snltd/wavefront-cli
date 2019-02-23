require_relative 'base'

# Define the proxy command.
#
class WavefrontCommandProxy < WavefrontCommandBase
  def description
    'view and manage Wavefront proxies'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "rename #{CMN} <id> <name>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     "versions #{CMN}"]
  end

  def _options
    [common_options,
     '-l, --long                list proxies in detail',
     '-a, --all                 list all proxies',
     '-o, --offset=n            start from nth proxy',
     '-O, --fields=F1,F2,...    only show given fields',
     '-f, --format=STRING       output format',
     '-L, --limit=COUNT         number of proxies to list']
  end
end
