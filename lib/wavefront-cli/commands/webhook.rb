require_relative './base'

# Define the webhook command.
#
class WavefrontCommandWebhook < WavefrontCommandBase
  def description
    'view and manage webhooks'
  end

  def _commands
    ["list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>"]
  end

  def _options
    [common_options,
     '-b, --brief               only list webhook names and IDs',
     '-o, --offset=n            start list from nth webhook',
     '-L, --limit=COUNT         number of webhooks to list',
     '-f, --userformat=STRING   output format']
  end
end
