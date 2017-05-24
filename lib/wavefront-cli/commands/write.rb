require_relative './base'

# Define the write command.
#
class WavefrontCommandWrite < WavefrontCommandBase
  def description
    'send data to a Wavefront proxy'
  end

  def _commands
    ['point [-DnV] [-c file] [-P profile] [-E proxy] [-t time] ' \
      '[-p port] [-H host] [-n] [-T tag...] <metric> <value>',
     'file [-DnV] [-c file] [-P profile] [-E proxy] [-H host] ' \
     '[-p port] [-n] [-F format] [-m metric] [-T tag...] <file>']
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
     'the two will be concatenated']
  end

  def postscript
    %(Files are whitespace separated, and fields can be defined
       with the -F option.  Use 't' for timestamp; 'm' for metric
       name; 'v' for value and 'T' for tags. Put 'T' last.)
  end
end
