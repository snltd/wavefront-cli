require 'inifile'
require 'pathname'
require_relative './constants.rb'

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

    attr_reader :opts, :cli_opts, :conf_file

    def initialize(conf_file, cli_opts = {})
      @conf_file = if cli_opts.key?(:config) && cli_opts[:config]
                     Pathname.new(cli_opts[:config])
                   else
                     conf_file
                   end

      @cli_opts = cli_opts.reject { |_k, v| v.nil? }

      @opts = DEFAULT_OPTS.merge(load_profile).merge(@cli_opts)
    end

    def load_profile
      #
      # Load in configuration options from the (optionally) given
      # section of an ini-style configuration file. If the file's
      # not there, we don't consider that an error. Returns a hash
      # of options which matches what Docopt gives us.
      #
      unless conf_file.exist?
        puts "config file '#{conf_file}' not found. Taking options " \
             'from command-line.'
        return {}
      end

      pf = cli_opts.fetch(:profile, 'default')

      puts "reading '#{pf}' profile from '#{conf_file}'" if cli_opts[:debug]

      IniFile.load(conf_file)[pf].each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
      end
    end
  end
end
