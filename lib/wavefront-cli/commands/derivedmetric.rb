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
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} [-v version] <id>",
     "create #{CMN} [-d description] [-T tag...] [-b] [-i interval] " \
     '[-r range] <name> <query>',
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long              list derived metrics in detail',
     '-a, --all               list all derived metrics',
     '-o, --offset=n          start list from nth derived metrics or ' \
                              'revision',
     '-O, --fields=F1,F2,...  only show given fields',
     '-L, --limit=COUNT       number of derived metrics or revisions to ' \
                              'list',
     '-v, --version=INTEGER   version of derived metrics',
     '-b, --obsolete          include obsolete metrics',
     '-T, --ctag=STRING       add customer tag',
     '-d, --desc=STRING       additional information about query',
     '-i, --interval=INTEGER  execute query every n minutes [default: 1]',
     '-r, --range=INTEGER     include results in the last n minutes ' \
                              '[default: 5]',
     '-f, --format=STRING   output format']
  end
end
