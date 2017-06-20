require_relative './base'

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
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "update #{CMN} <key=value> <id>"]
  end

  def _options
    [common_options,
     '-l, --long           list maintenance windows in detail',
     '-o, --offset=n       start from nth maintenance window',
     '-L, --limit=COUNT    number of maintenance windows to list',
     '-f, --format=STRING  output format']
  end
end
