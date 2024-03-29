# frozen_string_literal: true

require_relative 'base'

# Define the write command.
#
class WavefrontCommandWrite < WavefrontCommandBase
  def description
    'send data to Wavefront'
  end

  def _commands
    ["point #{CMN} [-iq] [-y proxy] [-s time] " \
     '[-p port] [-H host] [-T tag...] [-u method] [-S socket] <metric> ' \
     '[--] <value>',
     "distribution #{CMN} [-iq] [-y proxy] " \
     '[-H host] [-p port] [-T tag...] [-u method] [-S socket] [-I interval] ' \
     '<metric> [--] <val>...',
     "file #{CMN} [-iq] [-y proxy] [-H host] " \
     '[-p port] [-F infileformat] [-m metric] [-T tag...] [-I interval] ' \
     '[-u method] [-S socket] <file>',
     "noise #{CMN} [-iq] [-y proxy] [-H host] [-p port] " \
     '[-T tag...] [-I interval] [-x value] [-X value] <metric>']
  end

  def _options
    [common_options,
     '-y, --proxy=URI            proxy endpoint',
     '-s, --ts=TIME              timestamp of data point (omit for "now")',
     '-H, --host=STRING          source host',
     '-p, --port=INT             Wavefront proxy port',
     '-T, --tag=TAG              point tag in key=value form',
     '-F, --infileformat=STRING  format of input file or stdin',
     '-m, --metric=STRING        the metric path to which contents of ' \
     'a file will be assigned. If the file contains a metric name, ' \
     'the two will be dot-concatenated, with this value first',
     '-i, --delta                increment metric by given value',
     "-I, --interval=INTERVAL    interval of distribution (default 'm'), or " \
     'time in seconds between noise values (default 1)',
     '-u, --using=METHOD         method by which to send points',
     '-S, --socket=FILE          Unix datagram socket',
     '-x, --min=NUMERIC          lower bound of random values (default -10)',
     '-X, --max=NUMERIC          upper bound of random values (default 10)',
     "-q, --quiet                don't report the points sent summary " \
     '(unless there were errors)']
  end

  def postscript
    'Files are whitespace separated, and fields can be defined ' \
    "with the '-F' option.  Use 't' for timestamp, 'm' for metric " \
    "name, 'v' for value, 's' for source, 'd' for a comma-separated " \
    "distribution, and 'T' for tags. Put 'T' last.  Currently " \
    "supported transport methods are 'http' (write to a proxy over HTTP: " \
    "the default); 'api' (write directly to Wavefront); 'proxy' (send raw " \
    "data to a proxy); and 'socket' (write to a local Unix socket)."
      .cmd_fold(TW, 0)
  end
end
