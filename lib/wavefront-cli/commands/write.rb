require_relative './base'

# Define the write command.
#
class WavefrontCommandWrite < WavefrontCommandBase
  def description
    'send data to a Wavefront proxy'
  end

  def _commands
    ['point [-DnViq] [-c file] [-P profile] [-E proxy] [-t time] ' \
     '[-p port] [-H host] [-T tag...] <metric> <value>',
     'file [-DnViq] [-c file] [-P profile] [-E proxy] [-H host] ' \
     '[-p port] [-F format] [-m metric] [-T tag...] ' \
     '[-r rate] <file>']
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
     "-q, --quiet                don't report the points sent summary " \
     '(unless there were errors)',
     '-r, --rate=INTEGER         throttle point sending to this many ' \
     'points per second']
  end

  def postscript
    'Files are whitespace separated, and fields can be defined ' \
    "with the '-F' option.  Use 't' for timestamp; 'm' for metric " \
    "name; 'v' for value, 's' for source, and 'T' for tags. Put 'T' " \
    'last.'.cmd_fold(TW, 0)
  end
end
