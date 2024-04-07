# frozen_string_literal: true

require_relative 'base'

# Define the accesspolicy command.
#
class WavefrontCommandAccesspolicy < WavefrontCommandBase
  def description
    "view and manage your Wavefront #{thing}"
  end

  def _commands
    ["describe #{CMN}",
     "update #{CMN}",
     "validate #{CMN} <ip>"]
  end

  def _options
    [common_options]
  end

  def sdk_class
    'AccessPolicy'
  end

  def sdk_file
    'accesspolicy'
  end

  def thing
    'access policy'
  end
end
