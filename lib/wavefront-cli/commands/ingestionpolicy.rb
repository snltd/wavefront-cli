# frozen_string_literal: true

require_relative 'base'

# Define the ingestionpolicy command.
#
class WavefrontCommandIngestionpolicy < WavefrontCommandBase
  def thing
    'ingestion policy'
  end

  def things
    'ingestion policies'
  end

  def sdk_class
    'IngestionPolicy'
  end

  def _commands
    ["list #{CMN} [-al] [-O fields] [-o offset] [-L limit]",
     "create #{CMN} [-d description] <name>",
     "describe #{CMN} <id>",
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-u] <file>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long              list #{things} in detail",
     "-a, --all               list all #{things}",
     "-o, --offset=n          start list from nth #{thing}",
     '-O, --fields=F1,F2,...  only show given fields',
     "-L, --limit=COUNT       number of #{things} to list",
     "-d, --desc=STRING       reason for #{thing}",
     "-u, --update            update an existing #{thing}"]
  end
end
