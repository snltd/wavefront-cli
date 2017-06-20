require_relative './base'

# Define the query command.
#
class WavefrontCommandQuery < WavefrontCommandBase
  def description
    'query the Wavefront API'
  end

  def _commands
    ["#{CMN} [-g granularity] [-s time] [-e time] [-f format] " \
           '[-ivO] [-S mode] [-N name] [-p points] <query>',
     "raw #{CMN} [-H host] [-s time] [-e time] [-f format] <metric>"]
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
     '-f, --format=STRING       output format']
  end
end
