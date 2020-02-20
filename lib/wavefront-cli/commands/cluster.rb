# frozen_string_literal: true

require_relative 'base'

# Define the monitored cluster command.
#
class WavefrontCommandCluster < WavefrontCommandBase
  def thing
    'monitored cluster'
  end

  def sdk_file
    'monitoredcluster'
  end

  def sdk_class
    'MonitoredCluster'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "create #{CMN} [-v version] <platform> <name> <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "set #{CMN} <key=value> <id>",
     tag_commands,
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>...",
     "merge #{CMN} <id_to> <id_from>"]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     "-a, --all               list all #{things}",
     "-o, --offset=n          start from nth #{thing}",
     '-O, --fields=F1,F2,...  only show given fields',
     "-L, --limit=COUNT       number of #{things} to list",
     "-u, --update            update an existing #{thing}",
     "-U, --upsert            import new or update existing #{thing}",
     "-v, --version=VERSION   version of #{thing}"]
  end
end
