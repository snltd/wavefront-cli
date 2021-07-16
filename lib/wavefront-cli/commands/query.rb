# frozen_string_literal: true

require_relative 'base'

# Define the query command.
#
class WavefrontCommandQuery < WavefrontCommandBase
  def description
    'run Wavefront queries'
  end

  def _commands
    ['aliases [-DV] [-c file] [-P profile]',
     "#{CMN} [-g granularity] [-s time] [-e time] " \
     '[-ikvCGKOW] [-S mode] [-N name] [-p points] [-F options] <query>',
     "raw #{CMN} [-H host] [-s time] [-e time] " \
     '[-F options] <metric>',
     "run #{CMN} [-g granularity] [-s time] [-e time] " \
     '[-F options] [-WkivO] [-S mode] [-N name] [-p points] <alias>']
  end

  def _options
    [common_options,
     '-g, --granularity=STRING  query granularity (d, h, m, or s)',
     '-s, --start=TIME          start of query window',
     '-e, --end=TIME            end of query window',
     '-N, --name=STRING         name identifying query',
     '-p, --points=INTEGER      maximum number of points to return',
     '-i, --inclusive           include matching series with no ' \
     'points inside the query window',
     '-v, --events              include events for matching series',
     '-S, --summarize=STRING    summarization strategy for bucketing ' \
     'points (mean, median, min, max, sum, count, last, first)',
     '-O, --obsolete            include metrics unreported for > 4 weeks',
     '-H, --host=STRING         host or source to query on',
     '-F, --format-opts=STRING  comma-separated options to pass to ' \
     'output formatter',
     '-k, --nospark             do not show sparkline',
     '-C, --nocache             do not use the query cache',
     '-K, --nostrict            allow points outside the query window',
     '-G, --histogram-view      use histogram view rather than metric',
     '-W, --nowarn              do not show API warning messages']
  end

  def postscript
    'The query command has an additional output format. Using ' \
    "'-f wavefront' produces output suitable for feeding back into a " \
    "proxy. Other output formats are 'yaml', 'json', 'ruby', "\
    "and 'csv'. CSV format options are 'headers' (print column headers); " \
    "'tagkeys' (print tags as key=value rather than value); and 'quote' " \
    '(force quoting of every CSV element).'.cmd_fold(TW, 0)
  end
end
