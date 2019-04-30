require_relative 'base'

# Define the apitoken command.
#
class WavefrontCommandApitoken < WavefrontCommandBase
  def description
    'view and manage API tokens'
  end

  def sdk_file
    'apitoken'
  end

  def sdk_class
    'ApiToken'
  end

  def _commands
    ["list #{CMN} [-O fields]",
     "create #{CMN}",
     "delete #{CMN} <id>",
     "rename #{CMN} <id> <name>",
     tag_commands]
  end

  def _options
    [common_options,
     '-O, --fields=F1,F2,...  only show given fields',
     '-f, --format=STRING   output format']
  end
end
