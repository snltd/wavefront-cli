# frozen_string_literal: true

require 'pathname'
require 'wavefront-sdk/credentials'
require_relative 'constants'

module WavefrontCli
  #
  # Options to commands can come from three sources, with the
  # following order of precedence: program defaults, a configuration
  # file, and command-line options. Docopt is not well suited to
  # this, as it will "fill in" any missing options with defaults,
  # producing a single hash which must be merged with values from
  # the config file. Assuming we give the command-line higher
  # precedence, a default value, not supplied by the user, will
  # override a value in the config file. The other way round, and
  # you can't override anything in the config file from the
  # command-line. I think this behaviour is far from unique to
  # Docopt.
  #
  # So, we have a hash of defaults, and we do the merging ourselves,
  # in this class. We trick Docopt into not using the defaults by
  # avoiding the magic string 'default: ' in our options stanzas.
  #
  class OptHandler
    include WavefrontCli::Constants

    attr_reader :opts

    def initialize(cli_opts = {})
      cred_opts = setup_cred_opts(cli_opts)
      cli_opts.compact!
      @opts = DEFAULT_OPTS.merge(load_profile(cred_opts)).merge(cli_opts)
    rescue WavefrontCli::Exception::ConfigFileNotFound => e
      abort "Configuration file '#{e}' not found."
    rescue Wavefront::Exception::InvalidConfigFile => e
      abort "Could not load configuration file '#{e.message}'."
    rescue Wavefront::Exception::MissingConfigProfile => e
      abort "Cannot find profile '#{e}'."
    end

    # Create an options hash to pass to the Wavefront::Credentials
    # constructor.
    # @param cli_opts [Hash] options from docopt, which may include
    #   the location of the config file and the stanza within it
    # @return [Hash] keys are none, one, or both of :file and :profile
    #
    def setup_cred_opts(cli_opts)
      cred_opts = cli_opts[:config] ? { raise_on_no_profile: true } : {}

      if cli_opts[:config]
        cred_opts[:file] = Pathname.new(cli_opts[:config])

        unless cred_opts[:file].exist?
          raise WavefrontCli::Exception::ConfigFileNotFound, cred_opts[:file]
        end
      end

      cred_opts[:profile] = cli_opts[:profile] if cli_opts[:profile]
      cred_opts
    end

    # Load credentials (and other config) using the SDK Credentials
    # class. This allows the user to override values with
    # environment variables
    #
    # @param cred_opts [Hash] options to pass to
    #   Wavefront::Credentials constructor
    # @return [Hash] keys are :token, :endpoint etc
    #
    def load_profile(cred_opts)
      creds = Wavefront::Credentials.new(cred_opts).config
      creds.transform_keys(&:to_sym)
    end
  end
end
