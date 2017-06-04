require_relative './base'

# Define the source command.
#
class WavefrontCommandSource < WavefrontCommandBase
  def description
    'view and manage source tags and descriptions'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long                 list sources in detail',
     '-o, --offset=n             start list from nth source',
     '-L, --limit=COUNT          number of sources to list',
     '-f, --format=STRING        output format']
  end
end
