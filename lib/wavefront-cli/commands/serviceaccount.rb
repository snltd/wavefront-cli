# frozen_string_literal: true

require_relative 'base'

# Define the service account command.
#
class WavefrontCommandServiceaccount < WavefrontCommandBase
  def thing
    'service account'
  end

  def sdk_file
    'serviceaccount'
  end

  def sdk_class
    'ServiceAccount'
  end

  def _commands
    ["list #{CMN} [-l] [-O fields]",
     "describe #{CMN} <id>",
     "create #{CMN} [-I] [-d description] [-m permission...] [-g group...] " \
     '[-k token...] <id>',
     "activate #{CMN} <id>",
     "deactivate #{CMN} <id>",
     "dump #{CMN}",
     "groups #{CMN} <id>",
     "privileges #{CMN} <id>",
     "join #{CMN} <id> <group>...",
     "leave #{CMN} <id> <group>...",
     "grant #{CMN} <privilege> to <id>",
     "revoke #{CMN} <privilege> from <id>",
     "set #{CMN} <key=value> <id>",
     "import #{CMN} [-u] <file>",
     "search #{CMN} [-al] [-o offset] [-L limit] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-I, --inactive           create an inactive #{thing}",
     "-d, --desc=STRING        description of #{thing}",
     "-m, --permission=STRING  give #{thing} this permission",
     "-g, --group=STRING       add #{thing} to this user group",
     '-k, --apitoken=STRING    API token']
  end
end
