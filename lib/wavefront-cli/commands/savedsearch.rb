require_relative './base'

# Define the saved search command.
#
class WavefrontCommandSavedsearch < WavefrontCommandBase
  def description
    'view and manage saved searches'
  end

  def sdk_file
    'savedsearch'
  end

  def sdk_class
    'SavedSearch'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>"]
  end

  def _options
    [common_options,
     '-l, --long                list saved searches in detail',
     '-o, --offset=n            start from nth saved search',
     '-L, --limit=COUNT         number of saved searches to list',
     '-f, --format=STRING       output format']
  end
end
