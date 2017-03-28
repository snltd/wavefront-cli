require 'yaml'
require 'json'
require_relative './constants'

module WavefrontCli
  #
  # Parent of all the CLI classes.
  #
  # To define a subcommand 'cmd', you must define a method 'do_cmd'.
  # The dispatch() method will find it, and call it.
  #
  class Base
    attr_accessor :wf, :options, :klass

    include WavefrontCli::Constants

    def initialize(options)
      @options = options

      if options.include?(:help) && options[:help]
        puts options
        exit 0
      end

      sdk_class = self.class.name.sub(/Cli/, '')
      require "wavefront-sdk/#{sdk_class.split('::').last.downcase}"
      @klass = Object.const_get(sdk_class)
    end

    def run
      @wf = klass.new(mk_creds, mk_opts)
      dispatch
    end

    def mk_creds
      #
      # Make a wavefront-sdk credentials object from standard
      # options.
      #
      { token: options[:token], endpoint: options[:endpoint] }
    end

    def mk_opts
      #
      # Make a common wavefront-sdk options object from standard CLI
      # options.
      #
      { debug: options[:debug], noop: options[:noop] }
    end

    def format_var
      #
      # The name of the option or config-file key which sets the
      # default output format for this class
      #
      (self.class.name.split('::').last.downcase + 'format').to_sym
    end

    def dispatch
      #
      # Works out the user's command by matching any option docopt
      # has set to 'true' with any 'do_' method in the class. Then
      # calls that method, and displays whatever it returns.
      #
      options.select { |_k, v| v == true }.each do |opt, _val|
        method = "do_#{opt}"
        return display(public_send(method), method) if respond_to?(method)
      end

      raise 'unsupported command'
    end

    def display(data, method)
      #
      # Display a Ruby object as JSON, YAML, or human-readable. For
      # human-readable to work, your class must implement a
      # 'humanize_cmd_output' method.
      #
      return if options[:noop]

      if data.key?('response')
        data = data['response']
      elsif data['status']['code'] == 200
        puts 'operation was successful'
        return
      else
        abort 'operation failed'
      end

      case options[format_var].to_sym
      when :json
        puts data.to_json
      when :yaml
        puts data.to_yaml
      when :human
        human_method = "humanize_#{method[3..-1]}_output"

        if respond_to?(human_method)
          send(human_method, data)
        else
          puts human_method
          p data
          raise 'human output format is not supported by this subcommand'
        end
      else
        raise 'unsupported output format'
      end
    end

    def validate_opts
      #
      # There are things we need to have. If we don't have them,
      # stop the user right now. Also, if we're in debug mode, print
      # out a hash of options, which can be very useful when doing
      # actual debugging. Some classes may have to override this
      # method. The writer, for instance, uses a proxy and has no
      # token.
      #
      raise 'Please supply an API token.' unless options[:token]
      raise 'Please supply an API endpoint.' unless options[:endpoint]
    end

    def key_width(hash)
      #
      # Give it a key-value hash, and it will return the size of
      # the first column to use when formatting that data. Used by
      # humanize() methods.
      #
      hash.keys.map(&:size).max + 2
    end
  end
end
