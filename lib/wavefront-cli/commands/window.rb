require_relative './base'

class WavefrontCommandWindow < WavefrontCommandBase
  def description
    'view and manage maintenance windows'
  end

  def _commands
    [ "list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
      "describe #{CMN} [-f format] <id>",
      "delete #{CMN} <id>",
    ]
  end

  def _options
    [ common_options,
      '-b, --brief                only list window names and IDs',
      '-o, --offset=n             start from nth maintenance window',
      '-L, --limit=COUNT          number of maintenance windows to list',
      '-f, --windowformat=STRING  output format'
    ]
  end
end