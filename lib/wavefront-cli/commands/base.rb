CMN = '[-DnV] [-c file] [-P profile] [-E endpoint] [-t token]'.freeze

# A base class which all command classes extend.
#
class WavefrontCommandBase
  # All commands have these options
  #
  def global_options
    ['-c, --config=FILE    path to configuration file',
     '-P, --profile=NAME   profile in configuration file',
     '-D, --debug          enable debug mode',
     '-n, --noop           do not perform API calls',
     '-V, --verbose        be verbose',
     '-h, --help           show this message']
  end

  # Many commands have these options
  #
  def common_options
    ['-E, --endpoint=URI       cluster endpoint',
     '-t, --token=TOKEN        Wavefront authentication token']
  end

  # Inheriting classes must override this method
  #
  def _options
    []
  end

  # Anything which takes tags provides the same interface
  #
  def tag_commands
    ["tags #{CMN} [-f format] <id>",
     "tag set #{CMN} <id> <tag>...",
     "tag clear #{CMN} <id>",
     "tag add #{CMN} <id> <tag>",
     "tag delete #{CMN} <id> <tag>"]
  end

  # Inheriting classes must override this method
  #
  def _commands
    []
  end

  # The command keyword
  #
  def word
    self.class.name.sub(/WavefrontCommand/, '').downcase
  end

  # Returns the name of the SDK class which does the work for this
  # command.
  #
  def sdk_class
    word.capitalize
  end

  # Returns the name of the SDK file which does the work for this
  # command.
  #
  def sdk_file
    word
  end

  # Returns a string describing the subcommands the command offers.
  #
  def commands(width = TW)
    _commands.flatten.each_with_object("Usage:\n") do |cmd, ret|
      ret.<< '  ' + "#{CMD} #{word} #{cmd}\n".cmd_fold(width) + "\n"
    end + "  #{CMD} #{word} --help"
  end

  # Returns a string describing the options the command understands.
  #
  def options
    width = option_column_width
    ret = "Global options:\n"
    global_options.each { |o| ret.<< opt_row(o, width) }
    ret.<< "\nOptions:\n"
    _options.flatten.each { |o| ret.<< opt_row(o, width) }
    ret
  end

  # Formats an option string.
  #
  def opt_row(opt, width)
    format("  %s %-#{width}s %s\n", *opt.split(/\s+/, 3))
      .opt_fold(TW, width + 5)
  end

  # Returns the width of the column containing short and long
  # options
  #
  def option_column_width
    (global_options + _options).flatten.map do |o|
      o.split(/\s+/, 3)[0..1].join(' ').size
    end.max
  end

  # Returns a string which will be printed underneath the options.
  #
  def postscript
    ''
  end

  # Returns a full options string which docopt understands
  #
  def docopt
    commands + "\n\n" + options + "\n" + postscript
  end
end

# Extensions to the String class to help with formatting.
#
class String
  # Fold long command lines. We can't break on a space inside
  # [square brackets] or it confuses docopt.
  #
  def cmd_fold(width = TW, indent = 10)
    gsub(/\s(?=\w+\])/, '^')
      .scan(/\S.{0,#{width - 8}}\S(?=\s|$)|\S+/).join("\n" + ' ' * indent)
      .tr('^', ' ')
  end

  # Fold long option lines with a hanging indent
  #
  def opt_fold(width = TW, indent = 10)
    bits = scan(/\S.{0,#{width - 8}}\S(?=\s|$)|\S+/)

    return '  ' + bits.first + "\n" if bits.size == 1

    opt_line = bits.shift
    rest = bits.join(' ').scan(/\S.{0,#{width - indent - 5}}\S(?=\s|$)|\S+/)
    '  ' + opt_line + "\n" + rest.map do |l|
      ' ' * (2 + indent) + l
    end.join("\n") + "\n"
  end
end
