# frozen_string_literal: true

require 'inifile'
require_relative 'exception'
require_relative 'base'

module WavefrontCli
  #
  # Create and manage a local configuration file.
  #
  class Config < WavefrontCli::Base
    attr_reader :config_file, :profile

    CONFIGURABLES = [
      { key: :token,
        text: 'Wavefront API token',
        default: nil,
        test: proc { |v| v =~ RX } },
      { key: :endpoint,
        text: 'Wavefront API endpoint',
        default: 'metrics.wavefront.com',
        test: proc { |v| v.end_with?('.wavefront.com') } },
      { key: :proxy,
        text: 'Wavefront proxy endpoint',
        default: 'wavefront',
        test: proc { true } },
      { key: :format,
        text: 'default output format',
        default: 'human',
        test: proc { |v| %w[human json yaml].include?(v) } }
    ].freeze

    RX = /^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$/

    def post_initialize(options)
      @config_file = _config_file
      @profile = options[:'<profile>'] || 'default'
    end

    def _sdk_class
      'Wavefront::Cluster'
    end

    def do_location
      config_file
    end

    def do_profiles
      read_config.sections.sort
    end

    def do_show
      present?
      File.read(config_file)
    end

    def do_about
      require 'wavefront-sdk/defs/version'

      { 'wf version': WF_CLI_VERSION,
        'wf path': CMD_PATH.realpath.to_s,
        'SDK version': WF_SDK_VERSION,
        'SDK location': WF_SDK_LOCATION.to_s,
        'Ruby version': RUBY_VERSION,
        'Ruby platform': Gem::Platform.local.os.capitalize }
    end

    def base_config
      return read_config if config_file.exist?

      puts "Creating new configuration file at #{config_file}."
      IniFile.new
    end

    def do_setup
      config = base_config

      if config.has_section?(profile)
        raise(WavefrontCli::Exception::ProfileExists, profile)
      end

      new_section = create_profile(profile)

      config = config.merge(new_section)
      config.write(filename: config_file)
    end

    def create_profile(profile)
      puts "Creating profile '#{profile}'."

      prof_arr = ["[#{profile}]"]

      CONFIGURABLES.each do |c|
        prof_arr << format('%<key>s=%<value>s',
                           key: c[:key],
                           value: read_thing(c))
      end

      IniFile.new(content: prof_arr.join("\n"))
    end

    def do_delete
      delete_section(profile, config_file)
    end

    def delete_section(profile, file)
      raw = read_config

      unless raw.has_section?(profile)
        raise(WavefrontCli::Exception::ProfileNotFound, profile)
      end

      raw.delete_section(profile)
      raw.write(filename: file)
    end

    def do_envvars
      %w[WAVEFRONT_ENDPOINT WAVEFRONT_TOKEN WAVEFRONT_PROXY].map do |v|
        format('%-20<var>s %<value>s', var: v, value: ENV[v] || 'unset')
      end
    end

    def do_cluster
      wf.describe
    end

    def validate_opts; end

    def no_api_response
      %w[do_location do_profiles do_show do_envvars do_about]
    end

    # def display(_data, _method); end

    def input_prompt(label, default)
      ret = format('  %<label>s', label: label)
      ret << format(' [%<value>s]', value: default) unless default.nil?
      "#{ret}:> "
    end

    # Read STDIN and strip the whitespace. The rescue is there to
    # catch a ctrl-d
    #
    def read_input
      $stdin.gets.strip
    rescue NoMethodError
      abort "\nInput aborted at user request."
    end

    # Read something, and return its checked, sanitized value
    # @return [String]
    #
    def read_thing(thing)
      print input_prompt(thing[:text], thing[:default])
      validate_thing_input(read_input, thing[:default], thing[:test])
    end

    def validate_thing_input(input, default, test)
      if input.empty?
        raise WavefrontCli::Exception::MandatoryValue if default.nil?

        input = default
      end

      return input if test.call(input)

      raise WavefrontCli::Exception::InvalidValue
    end

    def present?
      return true if config_file.exist?

      raise WavefrontCli::Exception::ConfigFileNotFound, config_file
    end

    # @return [Pathname] path to config file, from options, or from
    #   a constant if not supplied.
    #
    def _config_file
      Pathname.new(options[:config] || DEFAULT_CONFIG)
    end

    def read_config(_nocheck = false)
      present?
      IniFile.load(config_file)
    end
  end
end
