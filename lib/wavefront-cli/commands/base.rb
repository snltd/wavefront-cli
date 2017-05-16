CMN = '[-DnV] [-c file] [-P profile] [-E endpoint] [-t token]'.freeze

class WavefrontCommandBase

  # All commands have these options
  #
  def global_options
    [ '-c, --config=FILE    path to configuration file',
      '-P, --profile=NAME   profile in configuration file',
      '-D, --debug          enable debug mode',
      '-n, --noop           do not perform API calls',
      '-V, --verbose        be verbose',
      '-h, --help           show this message'
    ]
  end

  # Many commands have these options
  #
  def common_options
    [ '-E, --endpoint=URI       cluster endpoint',
      '-t, --token=TOKEN        Wavefront authentication token',
    ]
  end

  # Anything which takes tags provides the same interface
  #
  def tag_commands
    [ "tags #{CMN} [-f format] <id>",
      "tag set #{CMN} <id> <tag>...",
      "tag clear #{CMN} <id>",
      "tag add #{CMN} <id> <tag>",
      "tag delete #{CMN} <id> <tag>",
    ]
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

  def sdk_file
    word
  end

  # Returns a string describing the subcommands the command offers.
  #
  def commands
    _commands.flatten.each_with_object("Usage:\n") do |cmd, ret|
      ret.<< "  #{CMD} #{word} #{cmd}\n"
    end
  end

  # Returns a string describing the options the command understands.
  #
  def options
    (global_options + _options).flatten.
      each_with_object("Options:\n") do |opt, ret|
      ret.<< "  #{opt}\n"
    end
  end

  # Returns a string which will be printed underneath the options.
  #
  def postscript
    ''
  end

  # Returns a full options string which docopt understands
  #
  def docopt
    commands + "\n" + options + "\n" + postscript
  end
end
