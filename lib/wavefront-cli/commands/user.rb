require_relative './base'

# Define the user command.
#
class WavefrontCommandUser < WavefrontCommandBase
  def description
    'view and manage Wavefront users'
  end

  def _commands
    ["list #{CMN} [-l]",
     "describe #{CMN} [-f format] <id>",
     "delete #{CMN} <id>",
     "grant #{CMN} <privilege> <id>",
     "revoke #{CMN} <privilege> <id>"]
  end

  def _options
    [common_options,
     '-l, --long                list users in detail',
     '-f, --format=STRING       output format']
  end
end
