require_relative 'base'

# Define the user command.
#
class WavefrontCommandUser < WavefrontCommandBase
  def description
    'view and manage Wavefront users'
  end

  def _commands
    ["list #{CMN} [-l] [-O fields]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "import #{CMN} <file>",
     "grant #{CMN} <privilege> to <id>",
     "revoke #{CMN} <privilege> from <id>"]
  end

  def _options
    [common_options,
     '-l, --long                list users in detail',
     '-O, --fields=F1,F2,...    only show given fields',
     '-f, --format=STRING       output format']
  end
end
