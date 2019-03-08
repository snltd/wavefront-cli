require_relative 'base'

# Define the write command.
#
class WavefrontCommandWrite < WavefrontCommandBase
  def description
    'send data to Wavefront'
  end

  def _commands
    ['point [-DnViq] [-c file] [-P profile] [-E proxy] [-t time] ' \
     '[-p port] [-H host] [-T tag...] [-u method] [-S socket] <metric> ' \
     '<value>',
     'distribution [-DnViq] [-c file] [-P profile] [-E proxy] [-H host] ' \
     '[-p port] [-T tag...] [-u method] [-S socket] [-I interval] ' \
     '<metric> <val>...',
     'file [-DnViq] [-c file] [-P profile] [-E proxy] [-H host] ' \
     '[-p port] [-F infileformat] [-m metric] [-T tag...] [-I interval] ' \
     '[-u method] [-S socket] <file>']
  end

  def _options
    ['-E, --proxy=URI            proxy endpoint',
     '-t, --time=TIME            time of data point (omit to use ' \
     'current time)',
     '-H, --host=STRING          source host', \
     '-p, --port=INT             Wavefront proxy port',
     '-T, --tag=TAG              point tag in key=value form',
     '-F, --infileformat=STRING  format of input file or stdin',
     '-m, --metric=STRING        the metric path to which contents of ' \
     'a file will be assigned. If the file contains a metric name, ' \
     'the two will be dot-concatenated, with this value first',
     '-i, --delta                increment metric by given value',
     "-I, --interval=INTERVAL    interval of distribution (default 'm')",
     '-u, --using=METHOD         method by which to send points',
     '-S, --socket=FILE          Unix datagram socket',
     "-q, --quiet                don't report the points sent summary " \
     '(unless there were errors)']
  end

  def postscript
    'Files are whitespace separated, and fields can be defined ' \
    "with the '-F' option.  Use 't' for timestamp, 'm' for metric " \
    "name, 'v' for value, 's' for source, 'd' for a comma-separated " \
    "distribution, and 'T' for tags. Put 'T' last.  Currently " \
    "supported transport methods are 'socket' (write to a proxy: the " \
    "default); 'api' (write directly to Wavefront); 'http' (write to " \
    "a proxy over HTTP); and 'unix' (write to a local Unix socket)."
      .cmd_fold(TW, 0)
  end
end
