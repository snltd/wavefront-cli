require_relative 'base'

# Define the external link command.
#
class WavefrontCommandLink < WavefrontCommandBase
  def thing
    'external link'
  end

  def sdk_file
    'externallink'
  end

  def sdk_class
    'ExternalLink'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "create #{CMN} [-m regex] [-s regex] [-p str=regex...] <name> " \
     '<description> <template>',
     "delete #{CMN} <id>",
     "import #{CMN} [-u] <file>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{thing} to list",
     '-m, --metric-regex=REGEX metric filter regular expression',
     '-s, --source-regex=REGEX source filter regular expression',
     '-p, --point-regex=REGEX  point filter regular expression',
     "-u, --update             update an existing #{thing}"]
  end
end
