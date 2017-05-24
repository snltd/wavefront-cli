require_relative './base'

# Define the message command.
#
class WavefrontCommandMessage < WavefrontCommandBase
  def description
    'read and mark user messages'
  end

  def _commands
    ["list #{CMN} [-b] [-f format] [-o offset] [-L limit] [-a]",
     "mark #{CMN} [-f format] <id>"]
  end

  def _options
    [common_options,
     '-b, --brief                 only list link names and IDs',
     '-o, --offset=n              start from nth message',
     '-L, --limit=COUNT           number of messages to list',
     '-a, --all                   list all messages, not just unread',
     '-f, --messageformat=STRING  output format']
  end
end
