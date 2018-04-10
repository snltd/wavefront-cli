require_relative './base'

# Define the report command.
#
class WavefrontCommandReport < WavefrontCommandBase
  def description
    'send data directly to Wavefront'
  end

  def _commands
    ["point #{CMN} [-s time] [-H host] [-T tag...] <metric> <value>",
     "file #{CMN} [-H host] [-F format] [-m metric] [-T tag...] <file>"]
  end

  def _options
    [common_options,
     '-s, --time=TIME            time of data point (omit to use ' \
     'current time)',
     '-H, --host=STRING          source host', \
     '-T, --tag=TAG              point tag in key=value form',
     '-F, --infileformat=STRING  format of input file or stdin',
     '-m, --metric=STRING        the metric path to which contents of ' \
     'a file will be assigned. If the file contains a metric name, ' \
     'the two will be dot-concatenated, with this value first',
     "-q, --quiet                don't report the points sent summary " \
     '(unless there were errors)']
  end

  def postscript
    'Files are whitespace separated, and fields can be defined ' \
    "with the '-F' option.  Use 't' for timestamp; 'm' for metric " \
    "name; 'v' for value, 's' for source, and 'T' for tags. Put 'T' " \
    'last.'.cmd_fold(TW, 0)
  end
end
