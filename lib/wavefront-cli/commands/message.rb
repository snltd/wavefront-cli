require_relative 'base'

# Define the message command.
#
class WavefrontCommandMessage < WavefrontCommandBase
  def description
    "read and mark user #{things}"
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "read #{CMN} <id>",
     "mark #{CMN} <id>"]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     "-o, --offset=n          start from nth #{thing}",
     '-O, --fields=F1,F2,...  only show given fields',
     "-L, --limit=COUNT       number of #{things} to list",
     "-a, --all               list all #{things}, not just unread"]
  end
end
