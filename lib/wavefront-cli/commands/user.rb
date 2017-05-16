require_relative './base'

class WavefrontCommandUser < WavefrontCommandBase
  def description
    'view and manage Wavefront users'
  end

  def _commands
    [ "list #{CMN} [-b]",
      "describe #{CMN} [-f format] <user>",
      "delete #{CMN} <user>",
      "grant #{CMN} <privilege> <user>",
      "revoke #{CMN} <privilege> <user>",
    ]
  end

  def _options
    [ common_options,
      '-b, --brief               only list alert names and IDs',
      '-f, --userformat=STRING   output format',
    ]
  end
end
