require_relative './base'

class WavefrontCommandMessage < WavefrontCommandBase
  def description
    'read and mark user messages'
  end

  def _commands
    [ "list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
      "mark #{CMN} [-f format] <id>"
    ]
  end

  def _options
    [ common_options,
      '-b, --brief                 only list link names and IDs',
      '-o, --offset=n              start from nth message',
      '-L, --limit=COUNT           number of messages to list',
      '-f, --messageformat=STRING  output format',
    ]
  end
end