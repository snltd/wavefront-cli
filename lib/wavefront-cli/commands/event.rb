# frozen_string_literal: true

require_relative 'base'

# Define the event command.
#
class WavefrontCommandEvent < WavefrontCommandBase
  def description
    "open, close, view, and manage #{things}"
  end

  def _commands
    ["list #{CMN} [-l] [-O fields] [-s start] [-e end] [-L limit] [-o cursor]",
     "describe #{CMN} <id>",
     "create #{CMN} [-d description] [-s start] [-i | -e end] " \
     '[-S severity] [-T type] [-H host...] [-g tag...] [-N] <event>',
     "close #{CMN} [<id>]",
     "delete #{CMN} <id>",
     "set #{CMN} <key=value> <id>",
     "search #{CMN} [-al] [-o cursor] [-L limit] [-O fields] <condition>...",
     "wrap #{CMN} [-C command] [-d description] [-S severity] [-T type] " \
     '[-H host...] [-g tag...] <event>',
     tag_commands,
     "show #{CMN}"]
  end

  def _options
    [common_options,
     "-l, --long                list #{things} in detail",
     "-a, --all                 list all #{things}",
     "-o, --cursor=EVENT        start listing from given #{thing}",
     '-O, --fields=F1,F2,...    only show given fields',
     "-L, --limit=COUNT         number of #{things} to list",
     "-s, --start=TIME          start of listed #{things} or time at which " \
     "#{thing} begins",
     "-e, --end=TIME            end of listed #{things} or time at which " \
     "#{thing} ends",
     "-S, --severity=SEVERITY   severity of #{thing}",
     "-i, --instant             create an instantaneous #{thing}",
     "-T, --type=TYPE           type of #{thing}",
     "-d, --desc=STRING         description of #{thing}",
     "-H, --host=STRING         source to which #{thing} applies",
     '-N, --nostate             do not create a local file recording ' \
     "the #{thing}",
     "-g, --evtag=TAG           #{thing} tag",
     '-C, --command=COMMAND     command to run']
  end

  def postscript
    "View #{things} in detail using the 'query' command with the " \
      "'events()' function."
  end
end
