# frozen_string_literal: true

require_relative 'base'

# Define the maintenance window command.
#
class WavefrontCommandWindow < WavefrontCommandBase
  def thing
    'maintenance window'
  end

  def sdk_file
    'maintenancewindow'
  end

  def sdk_class
    'MaintenanceWindow'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "create #{CMN} -d reason [-s time] [-e time] " \
     '[-A alert_tag...] [-T host_tag...] [-H host...] <title>',
     "close #{CMN} <id>",
     "extend #{CMN} (by|to) <time> <id>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-u] <file>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>...",
     "ongoing #{CMN}",
     "pending #{CMN} [<hours>]"]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     "-a, --all               list all #{things}",
     "-o, --offset=n          start from nth #{thing}",
     '-O, --fields=F1,F2,...  only show given fields',
     "-L, --limit=COUNT       number of #{things} to list",
     "-u, --update            update an existing #{thing}",
     "-d, --desc=STRING       reason for #{thing}",
     "-s, --start=TIME        time at which #{thing} begins",
     "-e, --end=TIME          time at which #{thing} ends",
     "-A, --atag=STRING       alert tag to which #{thing} applies",
     "-H, --host=STRING       host to which #{thing} applies",
     "-T, --htag=STRING       host tag to which #{thing} applies"]
  end
end
