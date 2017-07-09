require_relative './base'

module WavefrontDisplayPrinter

  # Print the long indented descriptions of things
  #
  class Long < Base
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
      indent_str + format("%-#{kw}s%s", key, value)
        .opt_fold(TW, kw + indent_str.size, '').rstrip
    end
  end
end
