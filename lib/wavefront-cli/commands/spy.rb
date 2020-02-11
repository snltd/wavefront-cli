# frozen_string_literal: true

require_relative 'base'

# Define the spy command.
#
class WavefrontCommandSpy < WavefrontCommandBase
  def description
    'monitor traffic going into Wavefront'
  end

  def _common_opts
    "#{CMN} [-e timeout] [-p prefix] [-r rate] [-T tag_key...] [-m]"
  end

  def _commands
    ["#{_common_opts} [-H host] points",
     "#{_common_opts} [-H host] histograms",
     "#{_common_opts} [-H host] traces",
     "#{_common_opts} [-y type] ids"]
  end

  def _options
    [common_options,
     '-e, --end-after=SECONDS  stop spying after this many seconds',
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
      'is not guaranteed to remain stable.'
  end
end
