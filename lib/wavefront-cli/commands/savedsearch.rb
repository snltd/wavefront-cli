require_relative './base'

class WavefrontCommandSavedsearch < WavefrontCommandBase
  def description
    'view and manage saved searches'
  end

  def _commands
    [ "list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
      "describe #{CMN} [-f format] <id>",
      "delete #{CMN} <id>"
    ]
  end

  def _options
    [ '-b, --brief               only list saved search names and IDs',
      '-o, --offset=n            start from nth saved search',
      '-L, --limit=COUNT         number of saved searches to list',
      '-f, --savedsearchformat=STRING  output format'
    ]
  end
end
