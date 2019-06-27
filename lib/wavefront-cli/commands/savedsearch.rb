require_relative 'base'

# Define the saved search command.
#
class WavefrontCommandSavedsearch < WavefrontCommandBase
  def thing
    'saved search'
  end

  def things
    'saved searches'
  end

  def sdk_file
    'savedsearch'
  end

  def sdk_class
    'SavedSearch'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-u] <file>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list",
     "-u, --update             update an existing #{thing}"]
  end
end
