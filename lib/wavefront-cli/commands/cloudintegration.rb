# frozen_string_literal: true

require_relative 'base'

# Define the cloud integration command.
#
class WavefrontCommandCloudintegration < WavefrontCommandBase
  def thing
    'cloud integration'
  end

  def sdk_file
    'cloudintegration'
  end

  def sdk_class
    'CloudIntegration'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "undelete #{CMN} <id>",
     "enable #{CMN} <id>",
     "disable #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>...",
     "awsid #{CMN} generate",
     "awsid #{CMN} delete <external_id>",
     "awsid #{CMN} confirm <external_id>"]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     '-O, --fields=F1,F2,...   only show given fields',
     "-L, --limit=COUNT        number of #{things} to list",
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}"]
  end
end
