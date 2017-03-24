require 'pathname'
require 'socket'

module WavefrontCli
  module Constants
    DEFAULT_HOST = 'metrics.wavefront.com'
    DEFAULT_PERIOD_SECONDS = 600
    DEFAULT_FORMAT = :raw
    DEFAULT_PREFIX_LENGTH = 1
    DEFAULT_STRICT = true
    DEFAULT_OBSOLETE_METRICS = false
    FORMATS = [ :raw, :ruby, :graphite, :highcharts, :human ]
    ALERT_FORMATS = [:json, :human, :yaml]
    AGENT_FORMATS = [:json, :human, :yaml]
    SOURCE_FORMATS = [:ruby, :json, :human]
    DASH_FORMATS = [:json, :human, :yaml]
    DEFAULT_ALERT_FORMAT = :human
    DEFAULT_AGENT_FORMAT = :human
    DEFAULT_SOURCE_FORMAT = :human
    DEFAULT_DASH_FORMAT = :human
    GRANULARITIES = %w( s m h d )
    EVENT_STATE_DIR = Pathname.new('/var/tmp/wavefront/events')
    EVENT_LEVELS = %w(info smoke warn severe)
    DEFAULT_PROXY = 'wavefront'
    DEFAULT_PROXY_PORT = 2878
    DEFAULT_INFILE_FORMAT = 'tmv'

    # The CLI will use these options if they are not supplied on the
    # command line or in a config file
    #
    DEFAULT_OPTS = {
      endpoint:     DEFAULT_HOST,          # API endpoint
      proxy:        'wavefront',           # proxy endpoint
      port:         DEFAULT_PROXY_PORT,    # proxy port
      profile:      'default',             # stanza in config file
      host:         Socket.gethostname,    # source host
      prefixlength: DEFAULT_PREFIX_LENGTH, # no of prefix path elements
      strict:       DEFAULT_STRICT,        # points outside query window
      format:       DEFAULT_FORMAT,        # ts output format
      alertformat:  DEFAULT_ALERT_FORMAT,  # alert command output format
      agentformat:  DEFAULT_AGENT_FORMAT,  # agent command output format
      infileformat: DEFAULT_INFILE_FORMAT, # batch writer file format
      sourceformat: DEFAULT_SOURCE_FORMAT, # source output format
      dashformat:   DEFAULT_DASH_FORMAT,   # dashboard output format
    }.freeze
  end
end
