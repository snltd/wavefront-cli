require_relative './base'

# Define the event command.
#
class WavefrontCommandEvent < WavefrontCommandBase
  def description
    'open, close, view, and manage events'
  end

  def _commands
    ["list #{CMN} [-l] [-f format] [-s start] [-e end] [-L limit] " \
      '[-o cursor]',
     "describe #{CMN} [-f format] <id>",
     "create #{CMN} [-d description] [-s time] [-i | -e time] " \
     '[-S severity] [-T type] [-H host...] [-g tag...] [-N] <event>',
     "close #{CMN} [<id>]",
     "delete #{CMN} <id>",
     "update #{CMN} <key=value> <id>",
     "search #{CMN} [-f format] [-o offset] [-L limit] [-l] <condition>...",
     "wrap #{CMN} [-C command] [-d description] [-S severity] [-T type] " \
     '[-H host...] [-g tag...] <event>',
     tag_commands,
     'show [-D]']
  end

  def _options
    [common_options,
     '-l, --long                list events in detail',
     '-o, --cursor=EVENT        start listing from given event',
     '-L, --limit=COUNT         number of events to list',
     '-s, --start=TIME          time at which event begins',
     '-e, --end=TIME            time at which event ends',
     '-S, --severity=SEVERITY   severity of event',
     '-i, --instant             create an instantaneous event',
     '-T, --type=TYPE           type of event',
     '-d, --desc=STRING         description of event',
     '-H, --host=STRING         source to which event applies',
     '-N, --nostate             do not create a local file recording ' \
     'the event',
     '-g, --evtag=TAG           event tag',
     '-C, --command=COMMAND     command to run',
     '-f, --format=STRING       output format']
  end

  def postscript
    "View events in detail using the 'query' command with the " \
      "'events()' function."
  end
end
