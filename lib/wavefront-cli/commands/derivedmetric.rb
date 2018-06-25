require_relative 'base'

# Define the derivedmetric command.
#
class WavefrontCommandDerivedmetric < WavefrontCommandBase
  def description
    'view and manage derived metrics'
  end

  def sdk_file
    'derivedmetric'
  end

  def sdk_class
    'DerivedMetric'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] [-v version] <id>",
     "create #{CMN} [-d description] [-T tag...] [-O] [-i interval] " \
     '[-r range] <name> <query>',
     "import #{CMN} [-f format] <file>",
     "update #{CMN} <key=value> <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-f format] [-o offset] [-L limit] <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>...",
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long              list derived metrics in detail',
     '-o, --offset=n          start list from nth derived metrics or ' \
                              'revision',
     '-L, --limit=COUNT       number of derived metrics or revisions to ' \
                              'list',
     '-v, --version=INTEGER   version of derived metrics',
     '-O, --obsolete          include obsolete metrics',
     '-T, --tag=STRING        add customer tag',
     '-d, --desc=STRING       additional information about query',
     '-i, --interval=INTEGER  execute query every n minutes [default: 1]',
     '-r, --range=INTEGER     include results in the last n minutes ' \
                              '[default: 5]',
     '-f, --format=STRING   output format']
  end
end
