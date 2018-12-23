require 'pathname'

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

    # How many objects to get in each request when we are asked for
    # --all
    #
    ALL_PAGE_SIZE = 999

    # Default configuration file
    #
    DEFAULT_CONFIG = (Pathname.new(ENV['HOME']) + '.wavefront').freeze
  end
end
