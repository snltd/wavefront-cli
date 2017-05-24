require_relative './base'

# Define the proxy command.
#
class WavefrontCommandProxy < WavefrontCommandBase
  def description
    'view and manage Wavefront proxies'
  end

  def _commands
    ["list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "rename #{CMN} <id> <name>"]
  end

  def _options
    [common_options,
     '-b, --brief               only list proxy names and IDs',
     '-o, --offset=n            start from nth proxy',
     '-f, --proxyformat=STRING  output format',
     '-L, --limit=COUNT         number of proxies to list']
  end
end
