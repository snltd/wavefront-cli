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
     "create #{CMN} [-I] [-d description] [-p policy] [-r role...] " \
     '[-g group...] [-k usertoken...] <id>',
     "activate #{CMN} <id>",
     "delete #{CMN} <account>...",
     "deactivate #{CMN} <id>",
     "dump #{CMN}",
     "groups #{CMN} <id>",
     "roles #{CMN} <id>",
     "ingestionpolicy #{CMN} <id>",
     "join #{CMN} <id> <group>...",
     "leave #{CMN} <id> <group>...",
     "grant #{CMN} <permission> to <id>",
     "revoke #{CMN} <permission> from <id>",
     "set #{CMN} <key=value> <id>",
     "import #{CMN} [-uU] <file>",
     "apitoken list #{CMN} [-O fields] <id>",
     "apitoken create #{CMN} [-N name] <id>",
     "apitoken delete #{CMN} <id> <token_id>",
     "apitoken rename #{CMN} <id> <token_id> <name>",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}",
     "-I, --inactive           create an inactive #{thing}",
     "-d, --desc=STRING        description of #{thing}",
     "-r, --role=STRING        give #{thing} this role",
     "-p, --policy=STRING      give #{thing} this ingestion policy",
     "-g, --group=STRING       add #{thing} to this user group",
     '-N, --name=STRING        name of token',
     '-k, --usertoken=STRING   API token']
  end
end
