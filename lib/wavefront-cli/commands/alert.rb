require_relative './base'

class WavefrontCommandAlert < WavefrontCommandBase
  def description
    'view and manage alerts'
  end

  def _commands
    [ "list #{CMN} [-b] [-f format] [-o offset] [-L limit]",
      "describe #{CMN} [-f format] [-v version] <id>",
      "delete #{CMN} <id>",
      "undelete #{CMN} <id>",
      "history #{CMN} [-f format] [-S start] [-L limit] <id>",
      "import #{CMN} <file>",
      "snooze #{CMN} [-T time] <id>",
      "unsnooze #{CMN} <id>",
      "tags #{CMN} [-f format] <id>",
      "tag set #{CMN} <id> <tag>...",
      "tag clear #{CMN} <id>",
      "tag add #{CMN} <id> <tag>",
      "tag delete #{CMN} <id> <tag>",
      "summary #{CMN}"
    ]
  end

  def _options
    [ common_options,
      '-b, --brief              only list alert names and IDs',
      '-v, --version=INTEGER    describe only this version of alert',
      '-o, --offset=n           start from nth alert',
      '-L, --limit=COUNT        number of alerts to list',
      '-T, --time=SECONDS       how long to snooze (default 3600)',
      '-f, --alertformat=STRING output format',
    ]
  end
end
