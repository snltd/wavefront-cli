# frozen_string_literal: true

require_relative 'base'

# Define the apitoken command.
#
class WavefrontCommandApitoken < WavefrontCommandBase
  def description
    "view and your own #{things}"
  end

  def thing
    'API token'
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
     "rename #{CMN} <id> <name>"]
  end

  def _options
    [common_options,
     '-O, --fields=F1,F2,...  only show given fields']
  end
end
