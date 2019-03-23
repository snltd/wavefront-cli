require_relative '../constants'

module WavefrontDisplay
  #
  # Print human-friendly output. If a command requires a dedicated
  # handler to format its output, define a method with the same name
  # as that which fetches the data, in a WavefrontDisplay class,
  # extending this one.
  #
  # We provide #long_output() and #multicolumn() methods to solve
  # standard formatting problems. To use them, define a do_() method
  # but rather than printing the output, have it call the method.
  #
  class Base
    include WavefrontCli::Constants

    attr_reader :raw, :data, :options

    # @param raw_response [Map, Hash, Array] the data returned by the SDK
    #   response.
    # @param options [Hash] options from docopt
    #
    def initialize(raw_response, options = {})
      @raw = raw_response

      data = if raw_response.respond_to?(:items)
               raw_response.items
             else
               raw_response
             end

      @data = prioritize_keys(data, priority_keys)
      @options = options
    end

    # find the correct method to deal with the output of the user's
    # command.
    #
    def run(method)
      if method == 'do_list'
        run_list
      elsif method == 'do_search'
        run_search
      elsif respond_to?("#{method}_brief")
        send("#{method}_brief")
      elsif respond_to?(method)
        send(method)
      else
        long_output
      end
    end

    # Choose the correct list handler. The user can specifiy a long
    # listing with the --long options.
    #
    def run_list
      if options[:long]
        @data = filter_data(data, filter_fields_as_arr) if options[:fields]
        do_list
      elsif options[:fields]
        do_list_fields
      else
        do_list_brief
      end
    end

    # @return [Array[Hash]] modified version of data. Each hash will
    #   contain only the fields given in `fields`, in the given
    #   order
    # @param data [Array[Hash]]
    # @param fields [Array]
    #
    def filter_data(data, fields)
      data.map! do |d|
        fields.each_with_object({}) { |f, a| a[f] = d[f] if d.key?(f) }
      end
    end

    # Choose the correct search handler. The user can specifiy a long
    # listing with the --long options.
    #
    def run_search
      options[:long] ? do_search : do_search_brief
    end

    # Display classes can provide a do_method_code() method, which
    # handles <code> errors when running do_method(). (Code is 404
    # etc.)
    #
    # @param method [Symbol] the error method we wish to call
    #
    def run_error(method)
      return unless respond_to?(method)
      send(method)
      exit 1
    end

    # Keys which we wish to float to the top of descriptions and
    # long listing objects. Subclasses may define their own.
    #
    def priority_keys
      %i[id name]
    end

    def prioritize_keys(data, keys)
      return _prioritize_keys(data, keys) unless data.is_a?(Array)
      data.map { |e| _prioritize_keys(e, keys) }
    end

    # Move the given fields to the start of a Hash or Map
    # @param data [Hash, Map]
    # @param keys [Array[Symbol]] keys to float
    # @return [Hash, Map]
    #
    def _prioritize_keys(data, keys)
      keys.each.with_object(data.is_a?(Map) ? Map.new : {}) do |k, a|
        next unless data.key?(k)
        a[k] = data[k]
        data.delete(k)
      end.merge(data)
    rescue NoMethodError
      data
    end

    # Default display method for 'describe' and long-list methods.
    # Wraps around #_two_columns() giving you the chance to modify
    # @data on the fly
    #
    # @param fields [Array[Symbol]] a list of fields you wish to
    #   display. If this is nil, all fields are displayed.
    # @param modified_data [Hash, Array] lets you modify @data
    #   in-line. If this is truthy, it is used. Passing
    #   modified_data means that any fields parameter is ignored.
    #
    def long_output(fields = nil, modified_data = nil)
      if data.empty? || modified_data&.empty?
        puts 'No data.'
      else
        require_relative 'printer/long'
        puts WavefrontDisplayPrinter::Long.new(data, fields, modified_data)
        pagination_line
      end
    end

    def multicolumn(*columns)
      require_relative 'printer/terse'
      puts WavefrontDisplayPrinter::Terse.new(data, columns)
      pagination_line
    end

    # if this is a section of a larger dataset, say so
    #
    # rubocop:disable Metrics/AbcSize
    def pagination_line
      return unless raw.respond_to?(:moreItems) && raw.moreItems == true

      enditem = raw.limit.positive? ? raw.offset + raw.limit - 1 : 0
      puts format('List shows items %d to %d. Use -o and -L for more.',
                  raw.offset, enditem)
    rescue StandardError
      puts 'List shows paginated output. Use -o and -L for more.'
    end
    # rubocop:enable Metrics/AbcSize

    # Give it a key-value hash, and it will return the size of the first
    # column to use when formatting that data.
    #
    # @param hash [Hash] the data for which you need a column width
    # @param pad [Integer] the number of spaces you want between columns
    # @return [Integer] length of longest key + pad
    #
    def key_width(hash = {}, pad = 2)
      return 0 if hash.keys.empty?
      hash.keys.map(&:size).max + pad
    end

    # return [String] the name of the thing we're operating on, like
    #   'alert' or 'dashboard'.
    #
    def friendly_name
      self.class.name.split('::').last.gsub(/([a-z])([A-Z])/, '\\1 \\2')
          .downcase
    end

    # @return [Array] filter fields from -O option
    #
    def filter_fields_as_arr
      options[:fields].split(',')
    end

    # The following do_ methods are default handlers called
    # following their namesake operation in the corresponding
    # WavefrontCli class. They can be overriden in the inheriting
    # class.
    #
    def do_list
      long_output
    end

    def do_list_fields
      multicolumn(*filter_fields_as_arr.map(&:to_sym))
    end

    def do_list_brief
      multicolumn(:id, :name)
    end

    def do_import
      puts "Imported #{friendly_name}."
      long_output
    end

    def do_delete
      puts "Deleted #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_undelete
      puts "Undeleted #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_search_brief
      display_keys = ([:id] + options[:'<condition>'].map do |c|
        c.split(/\W/, 2).first.to_sym
      end).uniq

      if data.empty?
        puts 'No matches.'
      else
        multicolumn(*display_keys)
      end
    end

    def do_search
      if data.empty?
        puts 'No matches.'
      else
        long_output
      end
    end

    def do_tag_add
      puts "Tagged #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_tag_delete
      puts "Deleted tag from #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_tag_clear
      puts "Cleared tags on #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_tag_set
      puts "Set tags on #{friendly_name} '#{options[:'<id>']}'."
    end

    def do_tags
      if data.empty?
        puts "No tags set on #{friendly_name} '#{options[:'<id>']}'."
      else
        data.sort.each { |t| puts t }
      end
    end

    def do_queries
      if options[:brief]
        multicolumn(:condition)
      else
        multicolumn(:id, :condition)
      end
    end

    # Modify, in-place, the data structure to remove fields which
    # we deem not of interest to the user.
    #
    # @param keys [Symbol] keys you do not wish to be shown.
    # @return [Nil]
    #
    def drop_fields(*keys)
      if data.is_a?(Array)
        data.each { |i| i.delete_if { |k, _v| keys.include?(k.to_sym) } }
      else
        data.delete_if { |k, _v| keys.include?(k.to_sym) }
      end
    end

    # Modify, in-place, the @data structure to make times
    # human-readable. Automatically handles second and millisecond
    # epoch times. Currently only operates on top-level keys.
    #
    # param keys [Symbol, Array[Symbol]] the keys you wish to be
    #   turned into readable times.
    # return [Nil]
    #
    def readable_time(*keys)
      keys.each { |k| data[k] = human_time(data[k]) if data.key?(k) }
    end

    # As for #readable_time, but when @data is an array. For
    # instance in "firing" alerts
    #
    def readable_time_arr(*keys)
      data.map do |row|
        keys.each { |k| row[k] = human_time(row[k]) if row.key?(k) }
      end
    end

    # Make a time human-readable. Automatically deals with epoch
    # seconds and epoch milliseconds
    #
    # param t [Integer, String] a timestamp. If it's a string, it is
    #   converted to an int.
    # param force_utc [Boolean] force output in UTC. Currently only
    #   used for unit tests.
    # return [String] a human-readable timestamp
    #
    def human_time(time, force_utc = false)
      raise ArgumentError unless time.is_a?(Numeric) || time.is_a?(String)

      return 'FOREVER' if time == -1

      str = time.to_s
      fmt, out_fmt = time_formats(str)
      # rubocop:disable Style/DateTime
      ret = DateTime.strptime(str, fmt).to_time
      # rubocop:enable Style/DateTime
      ret = force_utc ? ret.utc : ret.localtime
      ret.strftime(out_fmt)
    end

    # How do we format a timestamp?
    # @param str [String] an epoch timestamp, as a string
    # @return [String, String] DateTime formatter, strptime formatter
    #
    def time_formats(str)
      if str =~ /^\d{13}$/
        ['%Q', HUMAN_TIME_FORMAT_MS]
      elsif str =~ /^\d{10}$/
        ['%s', HUMAN_TIME_FORMAT]
      else
        raise ArgumentError
      end
    end
  end
end
