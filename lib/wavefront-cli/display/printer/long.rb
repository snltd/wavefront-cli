require_relative './base'
require_relative '../../string'

module WavefrontDisplayPrinter
  #
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

    # Drop any fields not required.
    #
    # @param item [Hash, Map] the raw data
    # @param fields [Array[Symbol]] the fields we wish to keep
    # @return [Hash, Map]
    #
    def preen_fields(item, fields = nil)
      return item unless fields
      item.keep_if { |k, _v| fields.include?(k.to_sym) }
    end

    # Remove HTML and stuff
    #
    # @param [String] raw value
    # @return [String] value with all HTML stripped out
    #
    def preen_value(value)
      return value unless value.is_a?(String) && value =~ /<.*>/
      value.gsub(%r{<\/?[^>]*>}, '').delete("\n")
    end

    # Return true if this line is blank and we don't want to print
    # blank lines
    #
    # @param value [Object] thing to check
    # @return [Boolean]
    #
    def blank?(value)
      value.respond_to?(:empty?) && value.empty? && hide_blank
    end

    # Parse a line and add it to the output or pass it on to another
    # method which knows how to add it to the output.
    #
    # @param key [String] a key
    # @param value [Object] the value: could be anything
    # @return [Nil]
    #
    def parse_line(key, value)
      return if blank?(value)

      value = preen_value(value)

      if value.is_a?(Hash)
        add_hash(key, value)
      elsif value.is_a?(Array)
        add_array(key, value)
      else
        add_line(key, value)
      end
    end

    # Add a key-value pair to the output when value is an array. It
    # will put the key and the first value element on the first
    # line, with subsequent value elements aligned at the same
    # offset, but with no key. If any value element is a hash, it is
    # handled by a separate method. For instance:
    #
    # key    value1
    #        value2
    #        value3
    #
    # @param key [String] the key
    # @param value_arr [Array] an array of values
    # @return [Nil]
    #
    def add_array(key, value_arr)
      value_arr.each_with_index do |element, index|
        if element.is_a?(Hash)
          add_hash(key, element, value_arr.size, index)
        else
          add_line(index.zero? ? key : nil, element)
        end
      end
    end

    # Add a hash to the output. It will put the key on a line on its
    # own, followed by other keys indented. All values are aligned
    # to the same point.  If this hash is a member of an array, we
    # are able to print a horizontal rule at the end of it. We don't
    # do this if it is the final member of the array.
    #
    # For instance:
    #
    #  key
    #    subkey1    value1
    #    subkey2    value2
    #
    # @param key [String] the key
    # @param value [Hash] hash of values to display
    # @param size [Integer] the size of the parent array, if there
    #   is one
    # @param index [Integer] the index of this element in parent
    #   array, if there is one.
    # @return [Nil]
    #
    def add_hash(key, value, arr_size = 0, arr_index = 0)
      add_line(key) if arr_index.zero?
      @indent += indent_step
      @kw -= 2
      _two_columns([value], kw - indent_step)
      add_rule(kw) if arr_index + 1 < arr_size
    end

    # Add a horizontal rule, from the start of the second column to
    # just shy of the end of the terminal
    #
    def add_rule(kw)
      add_line(nil, '-' * (TW - kw - 4))
    end

    # Make the string which is prepended to each line.  Stepping is
    # controlled by @indent_step.
    #
    # @param indent [Integer] how many characters to indent by.
    #
    def mk_indent(indent)
      @indent_str = ' ' * indent
    end

    # Print a single line of output, handling the necessary
    # indentation and tabulation.
    #
    # @param key [String] what to print in the first (key) column.
    #   Make this an empty string to print
    # @param val [String, Numeric] what to print in the second column
    # @param tw [Integer] terminal width
    #
    def mk_line(key, value = '', tw = TW)
      return indent_str + ' ' * kw + value if !key || key.empty?

      indent_str + format("%-#{kw}s%s", key, value)
                   .fold(tw, kw + indent_str.size, '').rstrip
    end

    # Add a line, prepped by #mk_line() to the out array.
    #
    def add_line(*args)
      @out.<< mk_line(*args)
    end
  end
end
