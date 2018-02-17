# For development against a local checkout of the SDK, uncomment
# this block
#
# dir = Pathname.new(__FILE__).dirname.realpath.parent.parent.parent
# $LOAD_PATH.<< dir + 'lib'
# $LOAD_PATH.<< dir + 'wavefront-sdk' + 'lib'

require 'pathname'
require 'pp'
require 'docopt'
require_relative './version'
require_relative './exception'
require_relative './opt_handler'

CMD_DIR = Pathname.new(__FILE__).dirname + 'commands'

# Dynamically generate a CLI interface from files which describe
# each subcomand.
#
class WavefrontCliController
  attr_reader :args, :usage, :opts, :cmds, :tw

  def initialize(args)
    @args = args
    @cmds = load_commands
    @usage = docopt_hash
    cmd, opts = parse_args
    @opts = parse_opts(opts)
    pp @opts if @opts[:debug]
    hook = load_sdk(cmd, @opts)
    run_command(hook)
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
  def parse_args
    Docopt.docopt(usage[:default], version: WF_CLI_VERSION, argv: args)
  rescue Docopt::Exit => e
    cmd = args.empty? ? nil : args.first.to_sym

    abort e.message unless usage.keys.include?(cmd)

    begin
      [cmd, sanitize_keys(Docopt.docopt(usage[cmd], argv: args))]
    rescue Docopt::DocoptLanguageError => e
      abort "mangled command description:\n#{e.message}"
    rescue Docopt::Exit => e
      abort e.message
    end
  end

  def parse_opts(o)
    WavefrontCli::OptHandler.new(o).opts
  end

  # Get the SDK class we need to run the command we've been given.
  #
  # @param cmd [String]
  def load_sdk(cmd, opts)
    require_relative File.join('.', cmds[cmd].sdk_file)
    Object.const_get('WavefrontCli').const_get(cmds[cmd].sdk_class).new(opts)
  rescue WavefrontCli::Exception::UnhandledCommand
    abort 'Fatal error. Unsupported command.'
  rescue StandardError => e
    p e
  end

  def run_command(hook)
    hook.validate_opts
    hook.run
  rescue StandardError => e
    $stderr.puts "general error: #{e}"
    $stderr.puts "re-run with '-D' for stack trace." unless opts[:debug]
    $stderr.puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}" if opts[:debug]
    abort
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
  def import_command(f)
    return if f.extname != '.rb' || f.basename.to_s == 'base.rb'
    k_name = f.basename.to_s[0..-4]
    require(CMD_DIR + k_name)
    Object.const_get("WavefrontCommand#{k_name.capitalize}").new
  end

  # Symbolize, and remove dashes from option keys
  #
  # @param h [Hash] options hash
  # return [Hash] h with modified keys
  #
  def sanitize_keys(h)
    h.each_with_object({}) { |(k, v), r| r[k.to_s.delete('-').to_sym] = v }
  end
end
