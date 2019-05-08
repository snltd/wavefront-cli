require 'yaml'
require 'json'
require 'wavefront-sdk/validators'
require_relative 'constants'
require_relative 'exception'

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
    include WavefrontCli::Constants

    def initialize(options)
      @options = options
      sdk_class = _sdk_class
      @klass_word = sdk_class.split('::').last.downcase
      validate_input

      options_and_exit if options[:help]

      require File.join('wavefront-sdk', @klass_word)
      @klass = Object.const_get(sdk_class)

      send(:post_initialize, options) if respond_to?(:post_initialize)
    end

    # Normally we map the class name to a similar one in the SDK.
    # Overriding his method lets you map to something else.
    #
    def _sdk_class
      self.class.name.sub(/Cli/, '')
    end

    # Some subcommands don't make an API call, so they don't return
    # a Wavefront::Response object. You can override this method
    # with something which returns an array of methods like that.
    # They will bypass the usual response checking.
    #
    # @return [Array[String]] methods which do not include an API
    # response
    #
    def no_api_response
      []
    end

    def options_and_exit
      ok_exit(options)
    end

    # Print a message and exit 0
    #
    def ok_exit(message)
      puts message
      exit 0
    end

    def run
      @wf = klass.new(mk_creds, mk_opts)
      dispatch
    end

    # We normally validate with a predictable method name. Alert IDs
    # are validated with #wf_alert_id? etc. If you need to change
    # that, override this method.
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

    def validate_tags(key = :'<tag>')
      Array(options[key]).each do |t|
        begin
          send(:wf_tag?, t)
        rescue Wavefront::Exception::InvalidTag
          raise(WavefrontCli::Exception::InvalidInput,
                "'#{t}' is not a valid tag.")
        end
      end
    end

    def validate_id
      send(validator_method, options[:'<id>'])
    rescue validator_exception
      abort failed_validation_message(options[:'<id>'])
    end

    def failed_validation_message(input)
      format("'%s' is not a valid %s ID.", input, klass_word)
    end

    # Make a wavefront-sdk credentials object from standard
    # options.
    #
    # @return [Hash] containing `token` and `endpoint`.
    #
    def mk_creds
      { token:    options[:token],
        endpoint: options[:endpoint],
        agent:    "wavefront-cli-#{WF_CLI_VERSION}" }
    end

    # Make a common wavefront-sdk options object from standard CLI
    # options. We force verbosity on for a noop, otherwise we get no
    # output.
    #
    # @return [Hash] containing `debug`, `verbose`, and `noop`.
    #
    def mk_opts
      ret = { debug:   options[:debug],
              noop:    options[:noop] }

      ret[:verbose] = options[:noop] ? true : options[:verbose]

      ret.merge!(extra_options) if respond_to?(:extra_options)
      ret
    end

    # To allow a user to default to different output formats for
    # different object, we are able to define a format for each class.
    # instance, `alertformat` or `agentformat`. This method returns
    # such a string appropriate for the inheriting class.
    #
    # @return [Symbol] name of the option or config-file key which
    #   sets the default output format for this class
    #
    def format_var
      options[:format].to_sym
    rescue NoMethodError
      :human
    end

    # Works out the user's command by matching any options docopt has
    # set to 'true' with any 'do_' method in the class. Then calls that
    # method, and displays whatever it returns.
    #
    # @return [nil]
    # @raise WavefrontCli::Exception::UnhandledCommand if the
    #   command does not match a `do_` method.
    #
    # rubocop:disable Metrics/AbcSize
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
      m_list.sort_by(&:length).reverse_each do |m|
        if m.reject { |w| options[w.to_sym] }.empty?
          method = (%w[do] + m).join('_')
          return display(public_send(method), method)
        end
      end

      if respond_to?(:do_default)
        return display(public_send(:do_default), :do_default)
      end

      raise WavefrontCli::Exception::UnhandledCommand
    end
    # rubocop:enable Metrics/AbcSize

    # Display a Ruby object as JSON, YAML, or human-readable.  We
    # provide a default method to format human-readable output, but
    # you can override it by creating your own
    # `humanize_command_output` method
    # control how its output is handled by setting the `response`
    # instance variable.
    #
    # @param data [WavefrontResponse] an object returned by a
    #   Wavefront SDK method. This will contain 'response'
    #   and 'status' structures.
    # @param method [String] the name of the method which produced
    #   this output. Used to find a suitable humanize method.
    #
    # rubocop:disable Metrics/AbcSize
    def display(data, method)
      if no_api_response.include?(method)
        return display_no_api_response(data, method)
      end

      exit if options[:noop]

      %i[status response].each do |b|
        abort "no #{b} block in API response" unless data.respond_to?(b)
      end

      unless check_status(data.status)
        handle_error(method, data.status.code) if format_var == :human
        display_api_error(data.status)
      end

      handle_response(data.response, format_var, method)
    end
    # rubocop:enable Metrics/AbcSize

    # @param status [Map] status object from SDK response
    # @return System exit
    #
    def display_api_error(status)
      if  status.code == 404
        abort 'API path not found. Perhaps your account does not ' \
              'support this feature.'
      end

      msg = status.message || 'No further information'
      abort format('ERROR: API code %s: %s.', status.code, msg.chomp('.'))
    end

    def display_no_api_response(data, method)
      handle_response(data, format_var, method)
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
      if format == :human
        k = load_display_class
        k.new(resp, options).run(method)
      else
        parseable_output(format, resp)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def parseable_output(format, resp)
      options[:class] = klass_word
      options[:hcl_fields] = hcl_fields
      require_relative File.join('output', format.to_s)
      oclass = Object.const_get(format('WavefrontOutput::%s',
                                       format.to_s.capitalize))
      oclass.new(resp, options).run
    rescue LoadError
      raise(WavefrontCli::Exception::UnsupportedOutput,
            format("The '%s' command does not support '%s' output.",
                   options[:class], format))
    end
    # rubocop:enable Metrics/AbcSize

    def hcl_fields
      []
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
      unless options[:token]
        raise(WavefrontCli::Exception::CredentialError,
              'Missing API token.')
      end

      return true if options[:endpoint]
      raise(WavefrontCli::Exception::CredentialError,
            'Missing API endpoint.')
    end

    # Give it a path to a file (as a string) and it will return the
    # contents of that file as a Ruby object. Automatically detects
    # JSON and YAML. Raises an exception if it doesn't look like
    # either. If path is '-' then it will read STDIN.
    #
    # @param path [String] the file to load
    # @return [Hash] a Ruby object of the loaded file
    # @raise WavefrontCli::Exception::UnsupportedFileFormat if the
    #   filetype is unknown.
    # @raise pass through any error loading or parsing the file
    #
    # rubocop:disable Metrics/AbcSize
    def load_file(path)
      return load_from_stdin if path == '-'

      file = Pathname.new(path)

      raise WavefrontCli::Exception::FileNotFound unless file.exist?

      if file.extname == '.json'
        JSON.parse(IO.read(file))
      elsif file.extname == '.yaml' || file.extname == '.yml'
        YAML.safe_load(IO.read(file))
      else
        raise WavefrontCli::Exception::UnsupportedFileFormat
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Read STDIN and return a Ruby object, assuming that STDIN is
    # valid JSON or YAML. This is a dumb method, it does no
    # buffering, so STDIN must be a single block of data. This
    # appears to be a valid assumption for use-cases of this CLI.
    #
    # @return [Object]
    # @raise Wavefront::Exception::UnparseableInput if the input
    #   does not parse
    #
    def load_from_stdin
      raw = STDIN.read

      if raw.start_with?('---')
        YAML.safe_load(raw)
      else
        JSON.parse(raw)
      end
    rescue RuntimeError
      raise Wavefront::Exception::UnparseableInput
    end

    # Below here are common methods. Most are used by most classes,
    # but if they don't match a command described in the docopt
    # text, the dispatcher will never call them. So, there's no
    # harm inheriting unneeded things. Some classes override them.
    #
    def do_list
      list = if options[:all]
               wf.list(ALL_PAGE_SIZE, :all)
             else
               wf.list(options[:offset] || 0, options[:limit] || 100)
             end

      respond_to?(:list_filter) ? list_filter(list) : list
    end

    def do_describe
      wf.describe(options[:'<id>'])
    end

    def do_import
      raw = load_file(options[:'<file>'])

      begin
        prepped = import_to_create(raw)
      rescue StandardError => e
        puts e if options[:debug]
        raise WavefrontCli::Exception::UnparseableInput
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
      cannot_noop!
      k, v = options[:'<key=value>'].split('=', 2)
      wf.update(options[:'<id>'], k => v)
    end

    def do_search(cond = options[:'<condition>'])
      require 'wavefront-sdk/search'
      wfs = Wavefront::Search.new(mk_creds, mk_opts)
      query = conds_to_query(cond)
      wfs.search(search_key, query, range_hash)
    end

    # If the user has specified --all, override any limit and offset
    # values
    #
    def range_hash
      if options[:all]
        limit  = :all
        offset = ALL_PAGE_SIZE
      else
        limit  = options[:limit]
        offset = options[:offset] || options[:cursor]
      end

      { limit: limit, offset: offset }
    end

    # The search URI pattern doesn't always match the command name,
    # or class name. Override this method if this is the case.
    #
    def search_key
      klass_word
    end

    # Turn a list of search conditions into an API query
    #
    def conds_to_query(conds)
      conds.each_with_object([]) do |cond, aggr|
        key, value = cond.split(/\W/, 2)
        q = { key: key, value: value }
        q[:matchingMethod] = 'EXACT' if cond.start_with?("#{key}=")
        q[:matchingMethod] = 'STARTSWITH' if cond.start_with?("#{key}^")
        aggr.<< q
      end
    end

    # Most things will re-import with the POST method if you remove
    # the ID.
    #
    def import_to_create(raw)
      raw.each_with_object({}) do |(k, v), a|
        a[k.to_sym] = v unless k == 'id'
      end
    end

    # Return a detailed description of one item, if an ID has been
    # given, or all items if it has not.
    #
    def one_or_all
      if options[:'<id>']
        resp = wf.describe(options[:'<id>'])
        data = [resp.response]
      else
        options[:all] = true
        resp = do_list
        data = resp.response.items
      end

      [resp, data]
    end

    # Operations which do require multiple operations cannot be
    # perormed as a no-op. Drop in a call to this method for those
    # things. The exception is caught in controller.rb
    #
    def cannot_noop!
      raise WavefrontCli::Exception::UnsupportedNoop if options[:noop]
    end

    # A recursive function which fetches list of values from a
    # nested hash. Used by WavefrontCli::Dashboard#do_queries
    # @param obj [Object] the thing to search
    # @param key [String, Symbol] the key to search for
    # @param aggr [Array] values of matched keys
    # @return [Array]
    #
    def extract_values(obj, key, aggr = [])
      if obj.is_a?(Hash)
        obj.each_pair do |k, v|
          if k == key && !v.to_s.empty?
            aggr.<< v
          else
            extract_values(v, key, aggr)
          end
        end
      elsif obj.is_a?(Array)
        obj.each { |e| extract_values(e, key, aggr) }
      end

      aggr
    end
  end
end
