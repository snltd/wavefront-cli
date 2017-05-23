require 'pathname'
require 'yaml'
require 'json'
require 'wavefront-sdk/validators'
require_relative './constants'
require_relative './exception'
require_relative './human_output'

module WavefrontCli
  #
  # Parent of all the CLI classes. This class uses metaprogramming
  # techniques to try to make adding new CLI commands and
  # sub-commands as simple as possible.
  #
  # To define a subcommand 'cmd', you only need add it to the
  # `docopt` description in the relevant section, and create a
  # method 'do_cmd'.  The WavefrontCli::Base::dispatch() method will
  # find it, and call it. If your subcommand has multiple words,
  # like 'delete tag', your do method would be called
  # `do_delete_tag`. The `do_` methods are able to access the
  # Wavefront SDK object as `wf`, and all docopt options as
  # `options`.
  #
  class Base
    attr_accessor :wf, :options, :klass, :flags, :response,
                  :col1, :col2, :klass_word

    include WavefrontCli::Constants
    include Wavefront::Validators

    def initialize(options)
      @options = options
      @flags = {}
      @response = :quiet
      @col1 = 'id'
      @col2 = 'name'
      sdk_class = self.class.name.sub(/Cli/, '')
      @klass_word = sdk_class.split('::').last.downcase
      validate_input

      if options.include?(:help) && options[:help]
        puts options
        exit 0
      end

      require File.join('wavefront-sdk', @klass_word)
      @klass = Object.const_get(sdk_class)

      send(:post_initialize, options) if respond_to?(:post_initialize)
    end

    def run
      @wf = klass.new(mk_creds, mk_opts)
      dispatch
    end

    # We normally validate with a predictable method name. Alert IDs are
    # validated with #wf_alert_id? etc. If you need to change that, override
    # this method.
    #
    def validator_method
      "wf_#{klass_word}_id?".to_sym
    end

    def validator_exception
      Object.const_get(
        "Wavefront::Exception::Invalid#{klass_word.capitalize}Id")
    end

    def validate_input
      validate_id if options[:'<id>']
      validate_tags if options[:'<tag>']
      send(:extra_validation) if respond_to?(:extra_validation)
    end

    def validate_tags
      Array(options[:'<tag>']).each do |t|
        begin
          send(:wf_tag?, t)
        rescue Wavefront::Exception::InvalidTag
          abort "'#{t}' is not a valid tag."
        end
      end
    end

    def validate_id
      send(validator_method, options[:'<id>'])
    rescue validator_exception
      abort "'#{options[:'<id>']}' is not a valid #{klass_word} ID."
    end

    # Make a wavefront-sdk credentials object from standard
    # options.
    #
    # @return [Hash] containing `token` and `endpoint`.
    #
    def mk_creds
      { token: options[:token], endpoint: options[:endpoint] }
    end

    # Make a common wavefront-sdk options object from standard CLI
    # options.
    #
    # @return [Hash] containing `debug`, `verbose`, and `noop`.
    #
    def mk_opts
      { debug: options[:debug], verbose: options[:verbose],
        noop: options[:noop] }
    end

    # To allow a user to default to different output formats for
    # different object, we define a format for each class. For
    # instance, `alertformat` or `agentformat`. This method returns
    # such a string appropriate for the inheriting class.
    #
    # @return [Symbol] name of the option or config-file key which
    #   sets the default output format for this class
    #
    def format_var
      (self.class.name.split('::').last.downcase + 'format').to_sym
    end

    # Works out the user's command by matching any options docopt has
    # set to 'true' with any 'do_' method in the class. Then calls that
    # method, and displays whatever it returns.
    #
    # @return [nil]
    # @raise 'unsupported command', if the command does not match a
    #   `do_` method.
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

      if respond_to?(:do_default)
        return display(public_send(:do_default), :do_default)
      end

      raise WavefrontCli::Exception::UnhandledCommand
    end

    # Display a Ruby object as JSON, YAML, or human-readable.  We
    # provide a default method to format human-readable output, but
    # you can override it by creating your own
    # `humanize_command_output` method. An upstream method can
    # control how its output is handled by setting the `response`
    # instance variable.
    #
    # @param data [Hash] a hash of information returned by a
    #   Wavefront SDK method. This will usually contain a `response`
    #   block, and if it does, it will be extracted and displayed.
    #   We assume the user is not interested in the `status` part of
    #   the API response if the command worked.
    # @param method [String] the name of the method which produced
    #   this output. Used to find a suitable humanize method.
    #
    def display(data, method)
      return if options[:noop] || response == :silent

      if data.is_a?(Hash)
        if data.key?('result') && data['result'] == 'ERROR'
          abort 'API ERROR: ' + data['message']
        end

        if data.key?('response') && response == :verbose
          data = data['response']
        elsif data['status'] && data['status'].key?('code') &&
              data['status']['code'] == 200
          puts 'operation was successful'
          return
        end

        data = data['items'] if data.key?('items')
      elsif response != :raw
        p data if options[:debug]
        abort 'operation failed'
      end

      format = options[format_var] ? options[format_var].to_sym : :human

      case format
      when :json
        puts data.to_json
      when :yaml
        puts data.to_yaml
      when :human
        human_method = "humanize_#{method[3..-1]}_output"

        if respond_to?(human_method)
          send(human_method, data)
        else
          HumanOutput.new(data, { brief: options[:brief],
                                  col1: col1,
                                  col2: col2 }).print
        end
      else
        raise 'unsupported output format'
      end
    end

    # There are things we need to have. If we don't have them, stop
    # the user right now. Also, if we're in debug mode, print out a
    # hash of options, which can be very useful when doing actual
    # debugging. Some classes may have to override this method. The
    # writer, for instance, uses a proxy and has no token.
    #
    def validate_opts
      raise 'Please supply an API token.' unless options[:token]
      raise 'Please supply an API endpoint.' unless options[:endpoint]
    end

    # Give it a path to a file (as a string) and it will return the
    # contents of that file as a Ruby object. Automatically detects
    # JSON and YAML. Raises an exception if it doesn't look like
    # either.
    #
    # @param path [String] the file to load
    # @return [Hash] a Ruby object of the loaded file
    # @raise 'Unsupported file format.' if the filetype is unknown.
    # @raise pass through any error loading or parsing the file
    #
    def load_file(path)
      file = Pathname.new(path)
      raise 'Import file does not exist.' unless file.exist?

      if file.extname == '.json'
        JSON.parse(IO.read(file))
      elsif file.extname == '.yaml' || file.extname == '.yml'
        YAML.safe_load(IO.read(file))
      else
        raise 'Unsupported file format.'
      end
    end
  end
end
