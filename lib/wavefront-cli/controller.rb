# frozen_string_literal: true

# For development against a local checkout of the SDK, uncomment
# this definition
#
# DEVELOPMENT = true

if defined?(DEVELOPMENT)
  dir = Pathname.new(__dir__).realpath.parent.parent.parent
  $LOAD_PATH.<< dir + 'lib'
  $LOAD_PATH.<< dir + 'wavefront-sdk' + 'lib'
end

require 'pathname'
require 'docopt'
require_relative 'version'
require_relative 'constants'
require_relative 'exception'
require_relative 'opt_handler'
require_relative 'stdlib/string'

CMD_DIR = Pathname.new(__dir__) + 'commands'

# Dynamically generate a CLI interface from files which describe
# each subcomand.
#
class WavefrontCliController
  attr_reader :args, :usage, :opts, :cmds, :tw

  include WavefrontCli::Constants

  def initialize(args)
    @args = args
    @cmds = load_commands
    @usage = docopt_hash
    cmd, opts = parse_args
    @opts = parse_opts(opts)
    cli_class_obj = load_cli_class(cmd, @opts)
    run_command(cli_class_obj)
  end

  # What you see when you do 'wf --help'
  # @return [String]
  #
  def default_help
    s = "Wavefront CLI\n\nUsage:\n  #{CMD} command [options]\n" \
        "  #{CMD} --version\n  #{CMD} --help\n\nCommands:\n"

    cmds.sort.each { |k, v| s.<< format("  %-18s %s\n", k, v.description) }
    s.<< "\nUse '#{CMD} <command> --help' for further information.\n"
  end

  # @return [Hash] command descriptions for docopt.
  #
  def docopt_hash
    cmds.each_with_object(default: default_help) do |(k, v), ret|
      ret[k.to_sym] = v.docopt
    end
  end

  # Parse the input. The first Docopt.docopt handles the default
  # options, the second works on the command.
  #
  # rubocop:disable Metrics/AbcSize
  def parse_args
    Docopt.docopt(usage[:default], version: WF_CLI_VERSION, argv: args)
  rescue Docopt::Exit => e
    cmd = args.empty? ? nil : args.first.to_sym

    abort e.message unless usage.key?(cmd)

    begin
      [cmd, sanitize_keys(Docopt.docopt(usage[cmd], argv: args))]
    rescue Docopt::DocoptLanguageError => e
      abort "Mangled command description:\n#{e.message}"
    rescue Docopt::Exit => e
      abort e.message
    end
  end
  # rubocop:enable Metrics/AbcSize

  def parse_opts(options)
    WavefrontCli::OptHandler.new(options).opts
  end

  # Get the CLI class we need to run the command we've been given.
  #
  # @param cmd [String]
  # @return WavefrontCli::cmd
  #
  # rubocop:disable Metrics/AbcSize
  def load_cli_class(cmd, opts)
    require_relative File.join('.', cmds[cmd].sdk_file)
    Object.const_get('WavefrontCli').const_get(cmds[cmd].sdk_class).new(opts)
  rescue WavefrontCli::Exception::UnhandledCommand
    abort 'Fatal error. Unsupported command. Please open a Github issue.'
  rescue WavefrontCli::Exception::InvalidInput => e
    abort "Invalid input. #{e.message}"
  rescue RuntimeError => e
    abort "Unable to run command. #{e.message}."
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def run_command(cli_class_obj)
    cli_class_obj.validate_opts
    cli_class_obj.run
  rescue Interrupt
    abort "\nOperation aborted at user request."
  rescue WavefrontCli::Exception::ConfigFileNotFound => e
    abort "Configuration file #{e}' not found."
  rescue WavefrontCli::Exception::CredentialError => e
    handle_missing_credentials(e)
  rescue WavefrontCli::Exception::MandatoryValue
    abort 'A value must be supplied.'
  rescue WavefrontCli::Exception::InvalidValue => e
    abort "Invalid value for #{e}."
  rescue WavefrontCli::Exception::ProfileExists => e
    abort "Profile '#{e}' already exists."
  rescue WavefrontCli::Exception::ProfileNotFound => e
    abort "Profile '#{e}' not found."
  rescue WavefrontCli::Exception::FileNotFound
    abort 'File not found.'
  rescue WavefrontCli::Exception::InsufficientData => e
    abort "Insufficient data. #{e.message}"
  rescue WavefrontCli::Exception::InvalidQuery => e
    abort "Invalid query. API message: '#{e.message}'."
  rescue WavefrontCli::Exception::SystemError => e
    abort "Host system error. #{e.message}"
  rescue WavefrontCli::Exception::UnparseableInput => e
    abort "Cannot parse input. #{e.message}"
  rescue WavefrontCli::Exception::UnparseableSearchPattern
    abort 'Searches require a key, a value, and a match operator.'
  rescue WavefrontCli::Exception::UnsupportedFileFormat
    abort 'Unsupported file format.'
  rescue WavefrontCli::Exception::UnsupportedOperation => e
    abort "Unsupported operation.\n#{e.message}"
  rescue WavefrontCli::Exception::UnsupportedOutput => e
    abort e.message
  rescue WavefrontCli::Exception::UnsupportedNoop
    abort 'Multiple API call operations cannot be performed as no-ops.'
  rescue WavefrontCli::Exception::UserGroupNotFound => e
    abort "Cannot find user group '#{e.message}'."
  rescue Wavefront::Exception::UnsupportedWriter => e
    abort "Unsupported writer '#{e.message}'."
  rescue WavefrontCli::Exception::ImpossibleSearch
    abort 'Search on non-existent key. Please use a top-level field.'
  rescue StandardError => e
    warn "general error: #{e}"
    backtrace_message(e)
    abort
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def backtrace_message(err)
    if opts[:debug]
      warn "Backtrace:\n\t#{err.backtrace.join("\n\t")}"
    else
      puts "Re-run command with '-D' for backtrace."
    end
  end

  # @param error [WavefrontCli::Exception::CredentialError]
  #
  def handle_missing_credentials(error)
    if DEFAULT_CONFIG.exist? && DEFAULT_CONFIG.file?
      abort "Credential error. #{error.message}"
    else
      puts 'No credentials supplied on the command line or via ' \
           'environment variables, and no configuration file found. ' \
           "Please run 'wf config setup' to create configuration."
        .fold(TW, 0)
      exit 1
    end
  end

  # Each command is defined in its own file. Dynamically load all
  # those commands.
  # @return [Hash] :command => CommandClass
  #
  def load_commands
    CMD_DIR.children.each_with_object({}) do |f, ret|
      k = import_command(f)
      ret[k.word.to_sym] = k if k
    end
  end

  # Load a command description from a file. Each is in its own class
  #
  # @param f [Pathname] path of file to load
  # return [Class] new class object defining command.
  #
  def import_command(path)
    return if path.extname != '.rb' || path.basename.to_s == 'base.rb'

    k_name = path.basename.to_s[0..-4]
    require(CMD_DIR + k_name)
    Object.const_get("WavefrontCommand#{k_name.capitalize}").new
  end

  # Symbolize, and remove dashes from option keys
  #
  # @param h [Hash] options hash
  # return [Hash] h with modified keys
  #
  def sanitize_keys(options)
    options.each_with_object({}) do |(k, v), r|
      r[k.to_s.delete('-').to_sym] = v
    end
  end
end
