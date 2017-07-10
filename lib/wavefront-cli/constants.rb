module WavefrontCli

  # Universal truths
  #
  module Constants
    HUMAN_TIME_FORMAT = '%F %T'.freeze
    HUMAN_TIME_FORMAT_MS = '%F %T.%3N'.freeze

    # The CLI will use these options if they are not supplied on the
    # command line or in a config file.
    #
    DEFAULT_OPTS = {
      endpoint: 'metrics.wavefront.com',
      format:   :human
    }.freeze
  end
end
