require_relative './base'

class WavefrontCommandIntegration < WavefrontCommandBase
  def description
    'view and manage cloud integrations'
  end

  def _commands
    [ 'list #{CMN} [-b] [-f format] [-o offset] [-L limit]',
      'describe #{CMN} [-f format] <id>',
      'delete #{CMN} <id>',
      'undelete #{CMN} <id>'
    ]
  end

  def _options
    [ common_options,
      '-b, --brief                    only list integration names and IDs',
      '-o, --offset=n                 start from nth integration',
      '-L, --limit=COUNT              number of integrations to list',
      '-f, --integrationformat=STRING output format'
    ]
  end
end
