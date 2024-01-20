# frozen_string_literal: true

require_relative 'base'

# Define the Configure command
#
class WavefrontCommandConfig < WavefrontCommandBase
  def description
    'create and manage local configuration, and display debug info'
  end

  def _commands
    ['location',
     'profiles [-D] [-c file]',
     'show [-D] [-c file] [<profile>]',
     'setup [-D] [-c file] [<profile>]',
     'delete [-D] [-c file] <profile>',
     'envvars',
     "cluster #{CMN}",
     'about']
  end

  def _options
    [common_options]
  end
end
