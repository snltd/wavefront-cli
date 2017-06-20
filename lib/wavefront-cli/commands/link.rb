require_relative './base'

# Define the external link command.
#
class WavefrontCommandLink < WavefrontCommandBase
  def description
    'view and manage external links'
  end

  def sdk_file
    'externallink'
  end

  def sdk_class
    'ExternalLink'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>"
    ]
  end

  def _options
    [common_options,
     '-l, --long               list external links in detail',
     '-o, --offset=n           start from nth external link',
     '-L, --limit=COUNT        number of external link to list',
     '-f, --format=STRING      output format']
  end
end
