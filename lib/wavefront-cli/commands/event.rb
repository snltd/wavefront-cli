require_relative './base'

# Define the event command.
#
class WavefrontCommandEvent < WavefrontCommandBase
  def description
    'open, close, view, and manage events'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-s start] [-e end] [-L limit] " \
      '[-o offset]',
     "describe #{CMN} [-f format] <id>",
     "create #{CMN} [-d description] [-s time] [-i | -e time] " \
     '[-S severity] [-T type] [-H host...] [-N] <event>',
     "close #{CMN} [<id>]",
     "delete #{CMN} <id>",
     "update #{CMN} <key=value> <id>",
     tag_commands,
     'show [-D]']
  end

  def _options
    [common_options,
     '-l, --long                list events in detail',
     '-o, --offset=n            start list from nth event',
     '-L, --limit=COUNT         number of events to list',
     '-s, --start=TIME          time at which event/window begins',
     '-e, --end=TIME            time at which even/window  ends',
     '-S, --severity=SEVERITY   severity of event',
     '-i, --instant             create an instantaneous event',
     '-T, --type=TYPE           type of event',
     '-d, --desc=STRING         description of event',
     '-H, --host=STRING         source to which event applies',
     '-N, --nostate             do not create a local file recording ' \
     'the event',
     '-f, --format=STRING        output format']
  end

  def postscript
    "View events in detail using the 'query' command with the " \
      "'events()' function."
  end
end
