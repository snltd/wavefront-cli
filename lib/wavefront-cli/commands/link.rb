require_relative './base'

class WavefrontCommandLink < WavefrontCommandBase
  def description
    'view and manage external links'
  end

  def _commands
    [ "list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
      "describe #{CMN} [-f format] <id>",
      "delete #{CMN} <id>",
    ]
  end

  def _options
    [ common_options,
      '-b, --brief              only list link names and IDs',
      '-o, --offset=n           start from nth external link',
      '-L, --limit=COUNT        number of external link to list',
      '-f, --linkformat=STRING  output format'
    ]
  end
end
