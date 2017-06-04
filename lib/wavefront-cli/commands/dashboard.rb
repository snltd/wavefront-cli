require_relative './base'

# Define the dashboard command.
#
class WavefrontCommandDashboard < WavefrontCommandBase
  def description
    'view and manage dashboards'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-o offset] [-L limit]",
     "describe #{CMN} [-f format] [-v version] <id>",
     "import #{CMN} [-f format] [-F] <file>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "history #{CMN} [-b] [-f format] [-o offset] [-L limit] <id>",
     tag_commands]
  end

  def _options
    [common_options,
     '-l, --long               list dashboards in detail',
     '-o, --offset=n           start list from nth dashboard or revision',
     '-L, --limit=COUNT        number of dashboards or revisions to list',
     '-v, --version=INTEGER    version of dashboard',
     '-f, --format=STRING      output format']
  end
end
