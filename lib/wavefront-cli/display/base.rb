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

      @data = data.is_a?(Map) ? Map(put_id_first(data)) : data
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
        do_list
      else
        do_list_brief
      end
    end

    # Choose the correct search handler. The user can specifiy a long
    # listing with the --long options.
    #
    def run_search
      if options[:long]
        do_search
      else
        do_search_brief
      end
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

    # If the data contains an 'id' key, move it to the start.
    #
    def put_id_first(data)
      data.key?(:id) ? { id: data[:id] }.merge(data) : data
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
      if data.empty? || (modified_data && modified_data.empty?)
        puts 'No data.'
      else
        require_relative 'printer/long'
        puts WavefrontDisplayPrinter::Long.new(data, fields, modified_data)
        pagination_line
      end
    end

    def multicolumn(*columns)
      require_relative 'printer/terse'
      puts WavefrontDisplayPrinter::Terse.new(data, *columns)
      pagination_line
    end

    # if this is a section of a larger dataset, say so
    #
    def pagination_line
      if raw.respond_to?(:moreItems) && raw.moreItems == true
        if raw.respond_to?(:offset) && raw.respond_to?(:limit)
          enditem = raw.limit > 0 ? raw.offset + raw.limit - 1 : 0
          puts format('List shows items %d to %d. Use -o and -L for more.',
                      raw.offset, enditem)
        else
          puts 'List shows paginated output. Use -o and -L for more.'
        end
      end
    end

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

    # The following do_ methods are default handlers called
    # following their namesake operation in the corresponding
    # WavefrontCli class. They can be overriden in the inheriting
    # class.
    #
    def do_list
      long_output
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
    def human_time(t, force_utc = false)
      raise ArgumentError unless t.is_a?(Numeric) || t.is_a?(String)
      str = t.to_s

      if str =~ /^\d{13}$/
        fmt = '%Q'
        out_fmt = HUMAN_TIME_FORMAT_MS
      elsif str =~ /^\d{10}$/
        fmt = '%s'
        out_fmt = HUMAN_TIME_FORMAT
      else
        raise ArgumentError
      end

      ret = DateTime.strptime(str, fmt).to_time
      ret = ret.utc if force_utc
      ret.strftime(out_fmt)
    end
  end
end
