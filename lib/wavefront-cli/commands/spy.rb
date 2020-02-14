# frozen_string_literal: true

require_relative 'base'

# Define the spy command.
#
class WavefrontCommandSpy < WavefrontCommandBase
  def description
    'monitor traffic going into Wavefront'
  end

  def _common_opts
    "#{CMN} [-e timeout] [-p prefix] [-r rate] [-m]"
  end

  def _commands
    ["points #{_common_opts} [-T tag_key...] [-H host]",
     "histograms #{_common_opts} [-T tag_key...] [-H host]",
     "spans #{_common_opts} [-T tag_key...] [-H host]",
     "ids #{_common_opts} [-y type]"]
  end

  def _options
    [common_options,
     '-e, --end-after=SECONDS  stop spying after (approximately) the given ' \
     'number of seconds',
     '-m, --timestamp          prefix each block of output with the current ' \
     'time',
     '-r, --rate=NUMBER        sampling rate to use, from 0.01 to 0.5 ' \
     '(default 0.01)',
     '-p, --prefix=STRING      only show metric names beginning with given ' \
     'string',
     '-H, --host=STRING        only show metrics from given host',
     '-T, --tag-key=TAG        only show metrics with the given point tag key',
     '-y, --type=STRING        one of METRIC, SPAN, HOST, or STRING']
  end

  def postscript
    "\nNOTE: This command uses the unofficial 'spy' API endpoint, which " \
      'is not guaranteed to remain stable.'.cmd_fold(TW, 0)
  end
end
