require_relative './base'

class WavefrontCommandWebhook < WavefrontCommandBase
  def description
    'view and manage webhooks'
  end

  def _commands
    [ "list #{CMN} [-b]",
      "describe #{CMN} [-f format] <webhook>",
      "delete #{CMN} <webhook>"
    ]
  end

  def _options
    [ common_options,
      '-b, --brief               only list webhook names and IDs',
      '-o, --offset=n            start list from nth webhook',
      '-L, --limit=COUNT         number of webhooks to list',
      '-f, --userformat=STRING   output format',
    ]
  end
end