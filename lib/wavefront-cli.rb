require 'pathname'
require 'pp'
require 'docopt'

# uncomment for development
$LOAD_PATH.<< Pathname.new(__FILE__).dirname.realpath.parent + 'lib'
$LOAD_PATH.<< Pathname.new(__FILE__).dirname.realpath.parent
              .parent + 'wavefront-sdk' + 'lib'

require 'wavefront-cli/version'
require 'wavefront-cli/opt_handler'

CMD_DIR = Pathname.new(__FILE__).parent.parent +
          'lib' + 'wavefront-cli' + 'commands'

# Dynamically generate a CLI interface from files which describe
# each subcomand.
#
class WavefrontCommand
  attr_reader :args, :usage, :opts, :cmds, :tw
  include WavefrontCli::Constants

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

  def default_help
    s = "Wavefront CLI\n\nUsage:\n  #{CMD} command [options]\n" \
        "  #{CMD} --version\n  #{CMD} --help\n\nCommands:\n"

    cmds.sort.each { |k, v| s.<< format("  %-15s %s\n", k, v.description) }
    s.<< "\nUse '#{CMD} <command> --help' for further information.\n"
  end

  # Make a hash of command descriptions for docopt.
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
    rescue Docopt::Exit => e
      abort e.message
    end
  end

  def parse_opts(o)
    WavefrontCli::OptHandler.new(conf_file, o).opts
  end

  def load_sdk(cmd, opts)
    require File.join('wavefront-cli', cmds[cmd].sdk_file)
    Object.const_get('WavefrontCli').const_get(cmds[cmd].sdk_class).new(opts)
  rescue WavefrontCli::Exception::UnhandledCommand
    abort 'Fatal error. Unsupported command.'
  rescue => e
    p e
  end

  def run_command(hook)
    hook.validate_opts
    hook.run
  rescue => e
    $stderr.puts "general error: #{e}"
    $stderr.puts "re-run with '-D' for stack trace." unless opts[:debug]
    $stderr.puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}" if opts[:debug]
    abort
  end

  # Each command is defined in its own file. Dynamically load all
  # those commands.
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

  # The default config file path.
  #
  # @return [Pathname] where we excpect to find a config file
  #
  def conf_file
    if ENV['HOME']
      Pathname.new(ENV['HOME']) + '.wavefront'
    else
      Pathname.new('/etc/wavefront/client.conf')
    end
  end

  # Symbolize, and remove dashes from option keys
  #
  # @param h [Hash] options hash
  # return [Hash] h with modified keys
  #
  def sanitize_keys(h)
    h.each_with_object({}) { |(k, v), r| r[k.delete('-').to_sym] = v }
  end
end

class String
  def fold(width = 80, indent = 0)
    scan(/.{#{width}}|.+/).map { |w| w.strip }.join("\n" + ' ' * indent)
  end
end
