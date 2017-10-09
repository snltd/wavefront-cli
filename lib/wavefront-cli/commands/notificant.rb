require_relative './base'

# Define the notificant command.
#
class WavefrontCommandNotificant < WavefrontCommandBase
  def description
    'view and manage Wavefront notification targets'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "import #{CMN} <file>",
     "delete #{CMN} <id>",
     "test #{CMN} <id>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long                list proxies in detail',
     '-o, --offset=n            start from nth proxy',
     '-f, --format=STRING       output format',
     '-L, --limit=COUNT         number of proxies to list']
  end
end
