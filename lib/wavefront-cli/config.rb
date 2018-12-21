require 'inifile'
require_relative 'base'

module WavefrontCli
  #
  # Create and manage a local configuration file. This class doesn't
  # fit many of the assumptions made by the Base class. (Primarily,
  # that it will consume the SDK.) Rather than split everything up,
  # we're going to do some bad programming and override a couple of
  # methods in the parent class to force different behaviour.
  #
  class Config < WavefrontCli::Base
    attr_reader :config_file, :profile

    CONFIGURABLES = [
      { key: :token,
        text: 'Wavefront API token',
        default: nil,
        ok?: proc { |v| v =~ RX } },
      { key: :endpoint,
        text: 'Wavefront API endpoint',
        default: 'metrics.wavefront.com',
        ok?: proc { |v| v.end_with?('.wavefront.com') } },
      { key: :proxy,
        text: 'Wavefront proxy endpoint',
        default: 'wavefront',
        ok?: proc { true } },
      { key: :format,
        text: 'default output format',
        default: 'human',
        ok?: proc { |v| %w[human json yaml].include?(v) } }
    ].freeze

    RX = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/

    def initialize(options)
      @options = options
      @config_file = _config_file
      @profile = options[:'<profile>'] || 'default'
    end

    def do_location
      puts config_file
    end

    def do_profiles
      read_config.sections.each { |s| puts s }
    end

    def do_show
      present?
      puts IO.read(config_file)
    end

    def do_setup
      if config_file.exist?
        raw = read_config
      else
        puts "Creating new configuration file at #{config_file}."
        raw = IniFile.new
      end

      abort "'#{profile}' profile already exists." if raw.has_section?(profile)

      puts "Creating profile '#{profile}'."

      str = CONFIGURABLES.each_with_object("[#{profile}]") do |t, a|
        a.<< format("\n%s=%s", t[:key], read_thing(t))
      end

      new = IniFile.new(content: str)
      raw = raw.merge(new)
      raw.write(filename: config_file)
    end

    def do_delete
      raw = read_config
      abort 'Profile not found.' unless raw.has_section?(profile)

      raw.delete_section(profile)
      raw.write(filename: config_file)
    end

    def do_envvars
      %w[WAVEFRONT_ENDPOINT WAVEFRONT_TOKEN WAVEFRONT_PROXY].each do |v|
        puts format('%-20s %s', v, ENV[v] || 'unset')
      end
    end

    def validate_opts; end

    def display(_data, _method); end

    def run
      dispatch
    end

    def read_thing(thing)
      print format('  %s', thing[:text])
      print format(' [%s]', thing[:default]) unless thing[:default].nil?
      print ':> '
      selection = STDIN.gets.chomp.strip

      if selection.empty?
        abort 'Value must be supplied.' if thing[:default].nil?
        selection = thing[:default]
      end

      abort "Invalid #{thing[:text]}." unless thing[:ok?].call(selection)

      selection
    rescue NoMethodError # probably ctrl-d
      puts
      abort
    end

    def present?
      abort 'No configuration file.' unless config_file.exist?
    end

    def _config_file
      Pathname.new(options[:config] || DEFAULT_CONFIG)
    end

    def read_config(_nocheck = false)
      present?
      IniFile.load(config_file)
    end
  end
end
