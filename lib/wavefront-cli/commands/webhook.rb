require_relative './base'

# Define the webhook command.
#
class WavefrontCommandWebhook < WavefrontCommandBase
  def description
    'view and manage webhooks'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long                list webhooks in detail',
     '-o, --offset=n            start list from nth webhook',
     '-L, --limit=COUNT         number of webhooks to list',
     '-f, --format=STRING       output format']
  end
end
