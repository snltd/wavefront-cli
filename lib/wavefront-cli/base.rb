require 'yaml'
require 'json'
require 'wavefront-sdk/validators'
require_relative './exception'

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
    attr_accessor :wf, :options, :klass, :klass_word

    include Wavefront::Validators

    def initialize(options)
      @options = options
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
        "Wavefront::Exception::Invalid#{klass_word.capitalize}Id"
      )
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
      options[:format].to_sym
      # (self.class.name.split('::').last.downcase + 'format').to_sym
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
    # `humanize_command_output` method
    # control how its output is handled by setting the `response`
    # instance variable.
    #
    # @param data [WavefrontResponse] an object returned by a
    #   Wavefront SDK method. This will contain a 'response'
    #   and 'status' structures.
    # @param method [String] the name of the method which produced
    #   this output. Used to find a suitable humanize method.
    #
    def display(data, method)
      exit if options[:noop]

      [:status, :response].each do |b|
        abort "no #{b} block in API response" unless data.respond_to?(b)
      end

      unless check_status(data.status)
        handle_error(method, data.status.code) if format_var == :human
        abort "API #{data.status.code}: #{data.status.message}."
      end

      resp = if data.response.respond_to?(:items)
               data.response.items
             else
               data.response
             end

      handle_response(resp, format_var, method)
    end

    def check_status(status)
      status.respond_to?(:result) && status.result == 'OK'
    end

    # This gives us a chance to catch different errors in
    # WavefrontDisplay classes. If nothing catches, them abort.
    #
    def handle_error(method, code)
      k = load_display_class
      k.new({}, options).run_error([method, code].join('_'))
    end

    def handle_response(resp, format, method)
      case format
      when :json
        puts resp.to_json
      when :yaml # We don't want the YAML keys to be symbols.
        puts JSON.parse(resp.to_json).to_yaml
      when :ruby
        p resp
      when :human
        k = load_display_class
        k.new(resp, options).run(method)
      else
        raise "Unknown output format '#{format}'."
      end
    end

    def load_display_class
      require_relative File.join('display', klass_word)
      Object.const_get(klass.name.sub('Wavefront', 'WavefrontDisplay'))
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

    # Below here are common methods. Most are used by most classes,
    # but if they don't match a command described in the docopt
    # text, the dispatcher will never call them. So, there's no
    # harm inheriting unneeded things. Some classes override them.
    #
    def do_list
      wf.list(options[:offset] || 0, options[:limit] || 100)
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    def do_import
      raw = load_file(options[:'<file>'])

      begin
        prepped = import_to_create(raw)
      rescue => e
        puts e if options[:debug]
        raise 'could not parse input.'
      end

      wf.create(prepped)
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_update
      k, v = options[:'<key=value>'].split('=')
      wf.update(options[:'<id>'], k => v)
    end

    def do_tags
      wf.tags(options[:'<id>'])
    end

    def do_tag_add
      wf.tag_add(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_delete
      wf.tag_delete(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_set
      wf.tag_set(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end

    # Most things will re-import with the POST method if you remove
    # the ID.
    #
    def import_to_create(raw)
      raw.delete_if { |k, _v| k == 'id' }
    end
  end
end
