module WavefrontDisplay
  #
  # Base class for the two printer classes
  #
  class DisplayPrinter
    attr_reader :out

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

    def to_s
      out.join("\n")
    end
  end

  # Print things which are per-row. The terse listings, primarily
  #
  class TerseDisplayPrinter < DisplayPrinter
    attr_reader :data, :keys, :fmt_string

    def initialize(data, *keys)
      # require 'json'
      # File.open('/tmp/1', 'w') { |f| f.puts data.to_json }
      @data = data
      @keys = keys
      @fmt_string = format_string.rstrip
      @out = prep_output
    end

    # @return [String] a Ruby format string for each line
    #
    def format_string
      lk = longest_keys
      keys.each_with_object('') { |k, out| out.<< "%-#{lk[k]}s  " }
    end

    # Find the length of the longest value for each member of @keys,
    # in @data.
    #
    # @return [Hash] with the same keys as :keys and Integer values
    #
    def longest_keys
      keys.each_with_object(Hash[*keys.map { |k| [k, 0] }.flatten]) \
      do |k, aggr|
        data.each do |obj|
          val = obj[k]
          val = val.join(', ') if val.is_a?(Array)
          aggr[k] = val.size if val.size > aggr[k]
        end
      end
    end

    # Print multiple column output. This method does no word
    # wrapping.
    #
    # @param keys [Symbol] the keys you want in the output. They
    #   will be printed in the order given.
    #
    def prep_output
      data.each_with_object([]) do |o, aggr|
        args = keys.map { |k| o[k].is_a?(Array) ? o[k].join(', ') : o[k] }
        aggr.<< format(fmt_string, *args).rstrip
      end
    end
  end

  # Print the long indented descriptions of things
  #
  class LongDisplayPrinter < DisplayPrinter
    attr_reader :indent, :indent_str, :indent_step, :kw, :hide_blank

    def initialize(data, fields = nil, modified_data = nil)
      @out = []
      @indent = 0
      @indent_step = 2
      @hide_blank = true
      _two_columns(modified_data || data, nil, fields)
    end

    # A recursive function which displays a key-value hash in two
    # columns. The key column width is automatically calculated.
    # Multiple-value 'v's are printed one per line. Hashes are nested.
    #
    # @param data [Array] and array of objects to display. Each object
    #   should be a hash.
    # @param indent [Integer] how many characters to indent the current
    #   data.
    # @kw [Integer] the width of the first (key) column.
    # @returns [Nil]
    #
    def _two_columns(data, kw = nil, fields = nil)
      [data].flatten.each do |item|
        preen_fields(item, fields)
        kw = key_width(item) unless kw
        @kw = kw unless @kw
        mk_indent(indent)
        item.each { |k, v| parse_line(k, v) }
        add_line(nil) if indent.zero?
      end

      @indent -= indent_step if indent > 0
      @kw += 2
      mk_indent(indent)
    end

    # Drop any fields not required
    #
    def preen_fields(item, fields)
      return item unless fields
      item.keep_if { |k, _v| fields.include?(k.to_sym) }
    end

    # Remove HTML and stuff
    #
    def preen_value(value)
      return value unless value.is_a?(String) && value.match(/<.*>/)
      value.gsub(%r{<\/?[^>]*>}, '').delete("\n")
    end

    def parse_line(k, v)
      return if v.respond_to?(:empty?) && v.empty? && hide_blank

      v = preen_value(v)

      if v.is_a?(Hash)
        add_new_hash(k, v, v, 0)
      elsif v.is_a?(Array)
        add_array(k, v)
      else
        add_line(k, v)
      end
    end

    # Print an array as part of two_column output
    #
    # @param k [String] the key (column 1)
    # @param v [String] the value (column 2)
    # @return [Nil]
    #
    def add_array(k, v)
      v.each_with_index do |value, index|
        if value.is_a?(Hash)
          add_new_hash(k, v, value, index)
        elsif index.zero?
          add_line(k, v.shift)
        else
          add_line(nil, value)
        end
      end
    end

    def add_new_hash(k, v, value, index)
      add_line(k) if index.zero?
      @indent += indent_step
      @kw -= 2
      _two_columns([value], kw - indent_step)
      add_line(nil, '-' * (TW - kw - 4)) unless index == v.size - 1
    end

    # Make the string which is prepended to each line.
    #
    # @param indent [Integer] how many characters to indent by.
    # Stepping is controlled by indent_tep
    #
    def mk_indent(indent)
      @indent_str = ' ' * indent
    end

    # Add a line, prepped by #mk_line() to the out array.
    #
    def add_line(*args)
      @out.<< mk_line(*args)
    end

    # Print a single line of output, handling the necessary
    # indentation and tabulation.
    #
    # @param key [String] what to print in the first (key) column.
    #   Make this an empty string to print
    # @param val [String, Numeric] what to print in the second column
    #
    def mk_line(key, value = '')
      return indent_str + ' ' * kw + value if !key || key.empty?
      indent_str + format("%-#{kw - 2}s%s", key, value)
        .opt_fold(TW, kw + indent_str.size + 2).rstrip
    end
  end
end
