# frozen_string_literal: true

# For development against a local checkout of the SDK, uncomment
# this definition
#
DEVELOPMENT = true

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
require_relative 'exception_handler'
require_relative 'stdlib/string'

CMD_DIR = Pathname.new(__dir__) + 'commands'

# Dynamically generate a CLI interface from files which describe
# each subcomand.
#
class WavefrontCliController
  attr_reader :args, :usage, :opts, :cmds, :tw

  include WavefrontCli::Constants
  include WavefrontCli::ExceptionMixins

  def initialize(args)
    @args = args
    @cmds = load_commands
    @usage = docopt_hash
    cmd, opts = parse_args
    @opts = parse_opts(opts)
    cli_class_obj = cli_class(cmd, @opts)
    run_command(cli_class_obj)
  rescue Interrupt
    handle_interrupt!
  end

  def handle_interrupt!
    raise if opts[:debug]

    puts "\nCancelled at user's request."
    exit 0
  end

  # What you see when you do 'wf --help'
  # @return [String]
  #
  # rubocop:disable Metrics/MethodLength
  def default_help
    s = ['Wavefront CLI',
         '',
         'Usage:',
         "  #{CMD} command [options]",
         "  #{CMD} --version",
         "  #{CMD} --help",
         '',
         'Commands:']

    cmds.sort.each do |k, v|
      s.<< format('  %-18<command>s %<desc>s',
                  command: k,
                  desc: v.description)
    end

    s.<< ''
    s.<< "Use '#{CMD} <command> --help' for further information."
    s.join("\n")
  end
  # rubocop:enable Metrics/MethodLength

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
  def parse_args
    Docopt.docopt(usage[:default], version: WF_CLI_VERSION, argv: args)
  rescue Docopt::Exit => e
    cmd = args.empty? ? nil : args.first.to_sym

    abort e.message unless usage.key?(cmd)
    parse_cmd(cmd)
  end

  # Parse a command.
  # @param cmd [String] given command
  #
  def parse_cmd(cmd)
    [cmd, sanitize_keys(Docopt.docopt(usage[cmd], argv: args))]
  rescue Docopt::DocoptLanguageError => e
    abort "Mangled command description:\n#{e.message}"
  rescue Docopt::Exit => e
    abort e.message
  end

  def parse_opts(options)
    WavefrontCli::OptHandler.new(options).opts
  end

  # Get the CLI class we need to run the command we've been given.
  #
  # @param cmd [String]
  # @return WavefrontCli::cmd
  #
  def cli_class(cmd, opts)
    load_cli_class(cmd, opts)
  rescue StandardError => e
    exception_handler(e)
  end

  def load_cli_class(cmd, opts)
    require_relative File.join('.', cmds[cmd].sdk_file)
    Object.const_get('WavefrontCli').const_get(cmds[cmd].sdk_class).new(opts)
  end

  def run_command(cli_class_obj)
    cli_class_obj.validate_opts
    cli_class_obj.run
  rescue StandardError => e
    exception_handler(e)
  end

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
    message = error.message.capitalize
    message.<<('.') unless message.end_with?('.')

    puts "Credential error. #{message}"

    unless DEFAULT_CONFIG.exist? && DEFAULT_CONFIG.file?
      puts
      puts 'You can pass credentials on the command line or via ' \
           "environment variables. You may also run 'wf config setup' to " \
           'create a config file.'.fold(TW, 0)
    end

    exit 1
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
    options.transform_keys { |k| k.to_s.delete('-').to_sym }
  end
end
