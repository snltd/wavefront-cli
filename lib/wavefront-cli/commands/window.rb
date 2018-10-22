require_relative 'base'

# Define the maintenance window command.
#
class WavefrontCommandWindow < WavefrontCommandBase
  def description
    'view and manage maintenance windows'
  end

  def sdk_file
    'maintenancewindow'
  end

  def sdk_class
    'MaintenanceWindow'
  end

  def _commands
    ["list #{CMN} [-al] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "create #{CMN} -d reason [-s time] [-e time] " \
     '[-A alert_tag...] [-T host_tag...] [-H host...] <title>',
     "close #{CMN} <id>",
     "extend #{CMN} (by|to) <time> <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-f format] [-o offset] [-L limit] <condition>...",
     "ongoing #{CMN}",
     "pending #{CMN} [<hours>]"]
  end

  def _options
    [common_options,
     '-l, --long           list maintenance windows in detail',
     '-a, --all            list all maintenance windows',
     '-o, --offset=n       start from nth maintenance window',
     '-L, --limit=COUNT    number of maintenance windows to list',
     '-d, --desc=STRING    reason for maintenance window',
     '-s, --start=TIME     time at which window begins',
     '-e, --end=TIME       time at which window ends',
     '-A, --atag=STRING    alert tag to which window applies',
     '-H, --host=STRING    host to which window applies',
     '-T, --htag=STRING    host tag to which window applies',
     '-f, --format=STRING  output format']
  end
end
