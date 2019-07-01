require_relative '../stdlib/string'

CMN = '[-DnVM] [-c file] [-P profile] [-E endpoint] [-t token] ' \
      '[-f format]'.freeze

# A base class which all command classes extend.
#
class WavefrontCommandBase
  def description
    "view and manage #{things}"
  end

  # All commands have these options
  # @return [Array]
  #
  def global_options
    ['-c, --config=FILE    path to configuration file',
     '-P, --profile=NAME   profile in configuration file',
     '-D, --debug          enable debug mode',
     '-n, --noop           do not perform API calls',
     '-V, --verbose        be verbose',
     '-f, --format=STRING  output format',
     '-M, --items-only     only show items in machine-parseable formats',
     '-h, --help           show this message']
  end

  # Many commands have these options
  # @return [Array]
  #
  def common_options
    ['-E, --endpoint=URI       cluster endpoint',
     '-t, --token=TOKEN        Wavefront authentication token']
  end

  # Inheriting classes must override this method
  # @return [Array]
  #
  def _options
    []
  end

  # Anything which takes tags provides the same interface
  # @return [Array]
  #
  def tag_commands
    ["tags #{CMN} <id>",
     "tag set #{CMN} <id> <tag>...",
     "tag clear #{CMN} <id>",
     "tag add #{CMN} <id> <tag>",
     "tag delete #{CMN} <id> <tag>",
     "tag pathsearch #{CMN} [-al] [-o offset] [-L limit] <word>"]
  end

  # Anything which takes ACLs provides the same interface
  # @return [Array]
  #
  def acl_commands
    ["acls #{CMN} <id>",
     "acl #{CMN} clear <id>",
     "acl #{CMN} grant (view | modify) on <id> to <name>...",
     "acl #{CMN} revoke (view | modify) on <id> from <name>..."]
  end

  # Inheriting classes must override this method
  # @return [Array]
  #
  def _commands
    []
  end

  # @return [String] the command keyword
  #
  def word
    self.class.name.sub(/WavefrontCommand/, '').downcase
  end

  def thing
    word
  end

  def things
    thing + 's'
  end

  # @return [String] the name of the SDK class which does the work
  #   for this command.
  #
  def sdk_class
    word.capitalize
  end

  # @return [String] the name of the SDK file which does the work
  #   for this command.
  #
  def sdk_file
    word
  end

  # @param term_width [Integer] force a terminal width. Makes
  #   testing far simpler.
  # @return [String] the subcommands the command offers.
  #
  #
  def commands(term_width = TW)
    _commands.flatten.each_with_object("Usage:\n") do |cmd, ret|
      ret.<< '  ' + "#{CMD} #{word} #{cmd}\n".cmd_fold(term_width) + "\n"
    end + "  #{CMD} #{word} --help"
  end

  # @param term_width [Integer] force a terminal width. Makes
  #   testing far simpler.
  # @return [String] the options the command understands.
  #
  # rubocop:disable Metrics/AbcSize
  def options(term_width = TW)
    width = option_column_width
    ret = ''

    unless global_options.empty?
      ret.<< "Global options:\n"
      global_options.each { |o| ret.<< opt_row(o, width, term_width) }
      ret.<< "\n"
    end

    ret.<< "Options:\n"
    _options.flatten.each { |o| ret.<< opt_row(o, width, term_width) }
    ret
  end
  # rubocop:enable Metrics/AbcSize

  # Formats an option string.
  #
  # @param opt [String] the option string
  # @param width [Integer] the width of the short + long options
  #   columns. This is used to indent following lines
  # @param term_width [Integer] the width of the user's terminal
  #
  def opt_row(opt, width, term_width = TW)
    format("  %s %-#{width}s %s\n", *opt.split(/\s+/, 3))
      .opt_fold(term_width, width + 5)
  end

  # @return [Integer] the width of the column containing short and
  #   long options
  #
  def option_column_width
    (global_options + _options).flatten.map do |o|
      o.split(/\s+/, 3)[0..1].join(' ').size
    end.max
  end

  # @return [String] which will be printed underneath the options.
  #
  def postscript
    ''
  end

  # @return [String] a full options string which docopt understands
  #
  def docopt
    commands + "\n\n" + options + "\n" + postscript
  end
end
