require 'yaml'
require 'json'
require_relative './constants'
require_relative './human_output'

module WavefrontCli
  #
  # Parent of all the CLI classes.
  #
  # To define a subcommand 'cmd', you must define a method 'do_cmd'.
  # The dispatch() method will find it, and call it.
  #
  class Base
    attr_accessor :wf, :options, :klass, :flags, :verbose_response

    include WavefrontCli::Constants

    def initialize(options)
      @options = options
      @flags = {}
      @verbose_response = false

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

    # Works out the user's command by matching any options docopt has
    # set to 'true' with any 'do_' method in the class. Then calls that
    # method, and displays whatever it returns.
    #
    def dispatch
      #
      # Take a list of do_ methods, remove the 'do_' from their name,
      # and break them into arrays of '_' separated words.
      #
      m_list = methods.select { |m| m.to_s.start_with?('do_') }.map do |m|
        m.to_s.split('_')[1..-1]
      end

      # Sort that array of arrays by length, longest first.  Then look
      # through each deconstructed method name and see if the user
      # supplied an option for each component. Call the first one that
      # matches. The order will ensure we match "do_delete_tags" before
      # we match "do_delete".
      #

      m_list.sort_by(&:length).reverse.each do |m|
        if m.reject { |w| options[w.to_sym] }.empty?
          method = (%w(do) + m).join('_')
          return display(public_send(method), method)
        end
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

      if data.key?('response') && verbose_response
        data = data['response']
      elsif data['status']['code'] == 200
        puts 'operation was successful'
        return
      else
        abort 'operation failed'
      end

      data = data['items'] if data.key?('items')

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
          HumanOutput.new(data)
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

    def load_file(path)
      #
      # Give it a path to a file (as a string) and it will return the
      # contents of that file as a Ruby object. Automatically detects
      # JSON and YAML. Raises an exception if it doesn't look like
      # either.
      #
      file = Pathname.new(path)
      raise 'Import file does not exist.' unless file.exist?

      if file.extname == '.json'
        JSON.parse(IO.read(file))
      elsif file.extname == '.yaml' || file.extname == '.yml'
        YAML.load(IO.read(file))
      else
        raise 'Unsupported file format.'
      end
    end
  end
end
