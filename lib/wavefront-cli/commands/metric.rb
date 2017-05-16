require_relative './base'

class WavefrontCommandMetric < WavefrontCommandBase
  def description
    'view metrics'
  end

  def _commands
    [ "describe #{CMN} [-f format] [-o offset] [-g glob...] <metric>" ]
  end

  def _options
    [ '-o, --offset=STRING        value to start from if results > 1000',
      '-g, --glob=STRING          return sources matching this pattern',
      '-f, --metricformat=STRING  output format',
    ]
  end
end
