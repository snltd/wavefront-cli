require_relative 'base'

# Define the Configure command
#
class WavefrontCommandConfig < WavefrontCommandBase
  def description
    'create and manage local configuration'
  end

  def _commands
    ['location',
     'profiles [-D] [-c file]',
     'show [-D] [-c file] [<profile>]',
     'setup [-D] [-c file] [<profile>]',
     'delete [-D] [-c file] <profile>',
     'envvars',
     'about']
  end

  def _options
    ['-c, --config=FILE    path to configuration file',
     '-D, --debug          enable debug mode']
  end

  def global_options
    []
  end
end
