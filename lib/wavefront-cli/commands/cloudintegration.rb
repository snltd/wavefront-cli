require_relative 'base'

# Define the cloud integration command.
#
class WavefrontCommandCloudintegration < WavefrontCommandBase
  def description
    'view and manage cloud integrations'
  end

  def sdk_file
    'cloudintegration'
  end

  def sdk_class
    'CloudIntegration'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "enable #{CMN} <id>",
     "disable #{CMN} <id>",
     "import #{CMN} <file>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long              list cloud integrations in detail',
     '-a, --all               list all cloud integrations',
     '-o, --offset=n          start from nth cloud integration',
     '-O, --fields=F1,F2,...  only show given fields',
     '-L, --limit=COUNT       number of cloud integrations to list',
     '-f, --format=STRING     output format']
  end
end
