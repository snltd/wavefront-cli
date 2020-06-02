# frozen_string_literal: true

require_relative 'base'

# Define the account command.
#
class WavefrontCommandAccount < WavefrontCommandBase
  def description
    "view and manage Wavefront #{things}"
  end

  def _commands
    ["list #{CMN} [-sSal] [-O fields] [-o offset] [-L limit]",
     "describe #{CMN} <id>",
     "create user #{CMN} [-m permission...] [-g group-id...] " \
     '[-r role-id...] [-i policy-id] <id>',
     "invite user #{CMN} [-m permission...] [-g group-id...] " \
     '[-r role-id...] [-i policy-id] <id>',
     "delete #{CMN} <id>",
     "dump #{CMN}",
     "import #{CMN} [-uU] <file>",
     "role #{CMN} add to <id> <role>...",
     "role #{CMN} remove from <id> <role>...",
     "roles #{CMN} <id>",
     "ingestionpolicy #{CMN} add to <id> <policy>",
     "ingestionpolicy #{CMN} remove from <id> <policy>",
     "ingestionpolicy #{CMN} <id>",
     "group #{CMN} add to <id> <group>...",
     "group #{CMN} remove from <id> <group>...",
     "groups #{CMN} <id>",
     "grant #{CMN} <permission> to <account>...",
     "revoke #{CMN} <permission> from <account>...",
     "permissions #{CMN} <id>",
     "business functions #{CMN} <id>",
     "validate #{CMN} [-l] <account>...",
     "search #{CMN} [-al] [-o offset] [-L limit] [-O fields] <condition>..."]
  end

  def _options
    [common_options,
     "-l, --long               list #{things} in detail",
     "-a, --all                list all #{things}",
     "-o, --offset=n           start from nth #{thing}",
     "-L, --limit=COUNT        number of #{things} to list",
     "-s, --service            list only service accounts",
     "-S, --user               list only user accounts",
     '-O, --fields=F1,F2,...   only show given fields',
     "-u, --update             update an existing #{thing}",
     "-U, --upsert             import new or update existing #{thing}",
     "-m, --permission=STRING  Wavefront permission name",
     "-g, --groupid=STRING     Wavefront usergroup ID",
     "-r, --roleid=STRING      Wavefront role ID",
     "-i, --policyid=STRING    Wavefront ingestion policy ID",
    ]
  end

  def postscript
    "Service accounts can be partially managed with this command, but " \
    "'wf serviceaccount' has more features.\n\nFor a list of permissions, " \
    "run 'wf settings list permissions'.".fold(TW, 0)
  end
end
