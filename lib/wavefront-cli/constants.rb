# frozen_string_literal: true

require 'pathname'

module WavefrontCli
  #
  # Universal truths
  #
  module Constants
    HUMAN_TIME_FORMAT = '%F %T'
    HUMAN_TIME_FORMAT_MS = '%F %T.%3N'

    # The CLI will use these options if they are not supplied on the
    # command line or in a config file.
    #
    DEFAULT_OPTS = {
      endpoint: 'metrics.wavefront.com',
      format: :human
    }.freeze

    # How many objects to get in each request when we are asked for
    # --all
    #
    ALL_PAGE_SIZE = 999

    # Default configuration file
    #
    DEFAULT_CONFIG = Pathname.new(Dir.home).join('.wavefront').freeze

    # Split regex for searches
    #
    SEARCH_SPLIT = /\^|!\^|=|!=|~|!~/

    # Where we store local event information
    #
    EVENT_STATE_DIR = Pathname.new('/var/tmp/wavefront')
  end
end
