require_relative 'base'

# Define the integration command.
#
class WavefrontCommandIntegration < WavefrontCommandBase
  def description
    "view and manage Wavefront #{things}"
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "install #{CMN} <id>",
     "uninstall #{CMN} <id>",
     "manifests #{CMN}",
     "status #{CMN} <id>",
     "statuses #{CMN}",
     "alert install #{CMN} <id>",
     "alert uninstall #{CMN} <id>",
     "installed #{CMN}",
     "manifests #{CMN}",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list"]
  end
end
