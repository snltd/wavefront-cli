require_relative 'base'

# Define the cloud integration command.
#
class WavefrontCommandIntegration < WavefrontCommandBase
  def description
    'view and manage Wavefront integrations'
  end

  def _commands
    ["list #{CMN} [-al] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "install #{CMN} <id>",
     "uninstall #{CMN} <id>",
     "manifests #{CMN}",
     "status #{CMN} <id>",
     "statuses #{CMN}",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     '-l, --long           list cloud integrations in detail',
     '-a, --all            list all cloud integrations',
     '-o, --offset=n       start from nth cloud integration',
     '-L, --limit=COUNT    number of cloud integrations to list',
     '-f, --format=STRING  output format']
  end
end
