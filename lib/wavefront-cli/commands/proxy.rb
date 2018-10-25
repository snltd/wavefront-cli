require_relative 'base'

# Define the proxy command.
#
class WavefrontCommandProxy < WavefrontCommandBase
  def description
    'view and manage Wavefront proxies'
  end

  def _commands
    ["list #{CMN} [-al] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "rename #{CMN} <id> <name>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>...",
     "#{CMN} versions"]
  end

  def _options
    [common_options,
     '-l, --long                list proxies in detail',
     '-a, --all                 list all proxies',
     '-o, --offset=n            start from nth proxy',
     '-f, --format=STRING       output format',
     '-L, --limit=COUNT         number of proxies to list']
  end
end
