require_relative 'base'

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
    ["list #{CMN} [-al] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "create #{CMN} [-m regex] [-s regex] [-p str=regex...] <name> " \
     '<description> <template>',
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long               list external links in detail',
     '-a, --all                list all external links',
     '-o, --offset=n           start from nth external link',
     '-L, --limit=COUNT        number of external link to list',
     '-m, --metric-regex=REGEX metric filter regular expression',
     '-s, --source-regex=REGEX source filter regular expression',
     '-p, --point-regex=REGEX  point filter regular expression',
     '-f, --format=STRING      output format']
  end
end
