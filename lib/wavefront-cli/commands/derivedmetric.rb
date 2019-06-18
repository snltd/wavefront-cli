require_relative 'base'

# Define the derivedmetric command.
#
class WavefrontCommandDerivedmetric < WavefrontCommandBase
  def thing
    'derived metric'
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
     "import #{CMN} [-u] <file>",
     "update #{CMN} <key=value> <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-o offset] [-L limit] <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     tag_commands]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     "-a, --all               list all #{things}",
     "-v, --version=INTEGER   describe only this version of #{thing}",
     "-o, --offset=n          start from nth #{thing} or revision",
     "-L, --limit=COUNT       number of #{things} or revisions to list",
     '-O, --fields=F1,F2,...  only show given fields',
     '-b, --obsolete          include obsolete metrics',
     '-T, --ctag=STRING       add customer tag',
     '-d, --desc=STRING       additional information about query',
     '-i, --interval=INTEGER  execute query every n minutes [default: 1]',
     '-r, --range=INTEGER     include results in the last n minutes ' \
                              '[default: 5]',
     "-u, --update             update an existing #{thing}"]
  end
end
