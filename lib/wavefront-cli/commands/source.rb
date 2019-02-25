require_relative 'base'

# Define the source command.
#
class WavefrontCommandSource < WavefrontCommandBase
  def description
    'view and manage source tags and descriptions'
  end

  def _commands
    ["list #{CMN} [-l] [-O fields] [-f format] [-o cursor] [-L limit] [-a]",
     "describe #{CMN} [-f format] <id>",
     "description set  #{CMN} <id> <description>",
     "description clear  #{CMN} <id>",
     "clear  #{CMN} <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>...",
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long               list sources in detail',
     '-o, --cursor=SOURCE      start list given source',
     '-O, --fields=F1,F2,...   only show given fields',
     '-L, --limit=COUNT        number of sources to list',
     '-a, --all                list all sources, including cluster',
     '-f, --format=STRING      output format']
  end
end
