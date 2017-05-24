require_relative './base'

# Define the user command.
#
class WavefrontCommandUser < WavefrontCommandBase
  def description
    'view and manage Wavefront users'
  end

  def _commands
    ["list #{CMN} [-b]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "grant #{CMN} <privilege> <id>",
     "revoke #{CMN} <privilege> <id>"]
  end

  def _options
    [common_options,
     '-b, --brief               only list alert names and IDs',
     '-f, --userformat=STRING   output format']
  end
end
