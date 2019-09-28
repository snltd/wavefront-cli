# frozen_string_literal: true

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
      extra_validation if respond_to?(:extra_validation)
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
      format("'%<value>s' is not a valid %<thing>s ID.",
             value: input,
             thing: klass_word)
    end

    # Make a wavefront-sdk credentials object from standard
    # options.
    #
    # @return [Hash] containing `token` and `endpoint`.
    #
    def mk_creds
      { token: options[:token],
        endpoint: options[:endpoint],
        agent: "wavefront-cli-#{WF_CLI_VERSION}" }
    end

    # Make a common wavefront-sdk options object from standard CLI
    # options. We force verbosity on for a noop, otherwise we get no
    # output.
    #
    # @return [Hash] containing `debug`, `verbose`, and `noop`.
    #
    def mk_opts
      ret = { debug: options[:debug],
              noop: options[:noop] }

      ret[:verbose] = options[:noop] ? true : options[:verbose]

      ret.merge!(extra_options) if respond_to?(:extra_options)
      ret
    end

    # To allow a user to default to different output formats for
    # different object types, we are able to define a format for
    # each class.  instance, `alertformat` or `proxyformat`. This
    # method returns such a symbol appropriate for the inheriting
    # class.
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
    def dispatch
      # Look through each deconstructed method name and see if the
      # user supplied an option for each component.  Call the first
      # one that matches. The order will ensure we match
      # "do_delete_tags" before we match "do_delete".
      #
      method_word_list.reverse_each do |w_list|
        if w_list.reject { |w| options[w.to_sym] }.empty?
          method = name_of_do_method(w_list)
          return display(public_send(method), method)
        end
      end

      if respond_to?(:do_default)
        return display(public_send(:do_default), :do_default)
      end

      raise WavefrontCli::Exception::UnhandledCommand
    end

    def name_of_do_method(word_list)
      (%w[do] + word_list).join('_')
    end

    # Take a list of do_ methods, remove the 'do_' from their name,
    # and break them into arrays of '_' separated words. The array
    # is sorted by length, longest first.
    #
    def method_word_list
      do_methods = methods.select { |m| m.to_s.start_with?('do_') }
      do_methods.map { |m| m.to_s.split('_')[1..-1] }.sort_by(&:length)
    end

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
    def display(data, method)
      if no_api_response.include?(method)
        return display_no_api_response(data, method)
      end

      exit if options[:noop]

      check_response_blocks(data)
      warning_message(data.status)
      status_error_handler(data, method)
      handle_response(data.response, format_var, method)
    end

    def status_error_handler(data, method)
      return if check_status(data.status)

      handle_error(method, data.status.code) if format_var == :human
      display_api_error(data.status)
    end

    def check_response_blocks(data)
      %i[status response].each do |b|
        abort "no #{b} block in API response" unless data.respond_to?(b)
      end
    end

    # Classes can provide methods which give the user information on
    # a given error code. They are named #handle_errcode_xxx, and
    # return a string.
    # @param status [Map] status object from SDK response
    # @return System exit
    #
    def display_api_error(status)
      method = format('handle_errcode_%<code>s', code: status.code).to_sym

      msg = if respond_to?(method)
              send(method, status)
            else
              status.message || 'No further information'
            end

      abort format('ERROR: API code %<code>s. %<message>s.',
                   code: status.code,
                   message: msg.chomp('.')).fold(TW, 7)
    end

    def warning_message(status)
      return unless status.status.between?(201, 299)

      puts format("API WARNING: '%<message>s'.", message: status.message)
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

    def parseable_output(output_format, resp)
      options[:class] = klass_word
      options[:hcl_fields] = hcl_fields
      cli_output_class(output_format).new(resp, options).run
    rescue LoadError
      raise(WavefrontCli::Exception::UnsupportedOutput,
            unsupported_format_message(output_format))
    end

    def cli_output_class(output_format)
      require_relative File.join('output', output_format.to_s)
      Object.const_get(format('WavefrontOutput::%<class>s',
                              class: output_format.to_s.capitalize))
    end

    def unsupported_format_message(output_format)
      format("The '%<command>s' command does not support '%<format>s' output.",
             command: options[:class], format: output_format)
    end

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
        raise(WavefrontCli::Exception::CredentialError, 'Missing API token.')
      end

      return true if options[:endpoint]

      raise(WavefrontCli::Exception::CredentialError, 'Missing API endpoint.')
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
    def load_file(path)
      return load_from_stdin if path == '-'

      file = Pathname.new(path)
      extname = file.extname.downcase

      raise WavefrontCli::Exception::FileNotFound unless file.exist?

      return load_json(file) if extname == '.json'
      return load_yaml(file) if %w[.yaml .yml].include?(extname)

      raise WavefrontCli::Exception::UnsupportedFileFormat
    end

    def load_json(file)
      JSON.parse(IO.read(file), symbolize_names: true)
    end

    def load_yaml(file)
      YAML.safe_load(IO.read(file), symbolize_names: true)
    end

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

    def do_dump
      cannot_noop!

      if options[:format] == 'yaml'
        ok_exit dump_yaml
      elsif options[:format] == 'json'
        ok_exit dump_json
      else
        abort format("Dump format must be 'json' or 'yaml'. " \
                     "(Tried '%<format>s')", options)
      end
    end

    def dump_yaml
      JSON.parse(item_dump_call.to_json).to_yaml
    end

    def dump_json
      item_dump_call.to_json
    end

    # Broken out into its own method because 'users' does not use
    # pagination
    #
    def item_dump_call
      wf.list(ALL_PAGE_SIZE, :all).response.items
    end

    def do_import
      raw = load_file(options[:'<file>'])
      errs = 0

      [raw].flatten.each do |obj|
        resp = import_object(obj)
        next if options[:noop]

        errs += 1 unless resp.ok?
        puts import_message(obj, resp)
      end

      exit errs
    end

    def import_message(obj, resp)
      format('%-15<id>s %-10<status>s %<message>s',
             id: obj[:id] || obj[:url],
             status: resp.ok? ? 'IMPORTED' : 'FAILED',
             message: resp.status.message)
    end

    def import_object(raw)
      raw = preprocess_rawfile(raw) if respond_to?(:preprocess_rawfile)
      prepped = import_to_create(raw)

      if options[:update]
        import_update(raw)
      else
        wf.create(prepped)
      end
    end

    def import_update(raw)
      wf.update(raw[:id], raw, false)
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    # Some objects support soft deleting. To handle that, call this
    # method from do_delete
    #
    def smart_delete(object_type = klass_word)
      cannot_noop!
      puts smart_delete_message(object_type)
      wf.delete(options[:'<id>'])
    end

    def smart_delete_message(object_type)
      desc = wf.describe(options[:'<id>'])
      word = desc.ok? ? 'Soft' : 'Permanently'
      format("%<soft_or_hard>s deleting %<object>s '%<id>s'",
             soft_or_hard: word,
             object: object_type,
             id: options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_set
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
    # rubocop:disable Metrics/MethodLength
    def range_hash
      offset_key = :offset

      if options[:all]
        limit  = :all
        offset = ALL_PAGE_SIZE
      elsif options[:cursor]
        offset_key = :cursor
        limit = options[:limit]
        offset = options[:cursor]
      else
        limit  = options[:limit]
        offset = options[:offset]
      end

      { limit: limit, offset_key => offset }
    end
    # rubocop:enable Metrics/MethodLength

    # The search URI pattern doesn't always match the command name,
    # or class name. Override this method if this is the case.
    #
    def search_key
      klass_word
    end

    # Turn a list of search conditions into an API query
    #
    # @param conds [Array]
    # @return [Array[Hash]]
    #
    def conds_to_query(conds)
      conds.map do |cond|
        key, value = cond.split(SEARCH_SPLIT, 2)
        { key: key, value: value }.merge(matching_method(cond))
      end
    end

    # @param cond [String] a search condition, like "key=value"
    # @return [Hash] of matchingMethod and negated
    #
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def matching_method(cond)
      case cond
      when /^\w+~/
        { matchingMethod: 'CONTAINS', negated: false }
      when /^\w+!~/
        { matchingMethod: 'CONTAINS', negated: true }
      when /^\w+=/
        { matchingMethod: 'EXACT', negated: false }
      when /^\w+!=/
        { matchingMethod: 'EXACT', negated: true }
      when /^\w+\^/
        { matchingMethod: 'STARTSWITH', negated: false }
      when /^\w+!\^/
        { matchingMethod: 'STARTSWITH', negated: true }
      else
        raise(WavefrontCli::Exception::UnparseableSearchPattern, cond)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity

    # Most things will re-import with the POST method if you remove
    # the ID.
    #
    def import_to_create(raw)
      raw.each_with_object({}) do |(k, v), a|
        a[k.to_sym] = v unless k == :id
      end
    rescue StandardError => e
      puts e if options[:debug]
      raise WavefrontCli::Exception::UnparseableInput
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
    # rubocop:disable Metrics/MethodLength
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
    # rubocop:enable Metrics/MethodLength
  end
end
