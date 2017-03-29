module WavefrontCli
  #
  # Print human-friendly output
  #
  class HumanOutput
    attr_reader :hide_blank, :indent_step, :kw, :indent

    # Create a new HumanOutput object
    #
    # @param data [Hash, Array] data to display. Many Wavefront objects
    #   have the data of interest in an 'items' key. If that is present,
    #   it will automatically be extracted and used.
    # @param options [Hash] hints on how to format the data. Valid keys
    #   are:
    #     'hide_blank' [Boolean] if this is true, lines with no, or
    #       empty, values will not be displayed.
    #     'indent_step' [Integer] when printing nested hashes, how many
    #       characters to indent. Defaults to 2
    # @returns [Nil]
    #
    def initialize(data, options = {})
      data = data['items'] if data.is_a?(Hash) && data.key?('items')
      data = [data] unless data.is_a?(Array)
      @hide_blank = options[:hide_blank] || true
      @indent_step = options[:indent_step] || 2
      two_columns(data)
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
    def two_columns(data, indent = 0, kw = nil)
      data.each do |row|
        kw = key_width(row) unless kw
        @kw = kw unless @kw
        @indent = ' ' * indent_step

        row.each do |k, v|
          next if (v.is_a?(String) || v.is_a?(Array)) && v.empty? && hide_blank

          if v.is_a?(String) && v.match(/<.*>/)
            v = v.gsub(%r{<\/?[^>]*>}, '').delete("\n")
          end

          if v.is_a?(Hash)
            print_line(k)
            two_columns([v], indent + indent_step, kw - indent_step)
          elsif v.is_a?(Array)
            print_line(k, v.shift)
            v.each { |w| print_line('', w) }
          else
            print_line(k, v)
          end
        end
        puts if indent.zero?
      end
    end

    # Print a single line of output
    # @param key [String] what to print in the first (key) column
    # @param val [String, Numeric] what to print in the second column
    # @param indent [Integer] number of leading spaces on line
    #
    def print_line(key, value = '')
      puts format("%s%-#{kw}s%s", indent, key, value)
    end

    # Give it a key-value hash, and it will return the size of the first
    # column to use when formatting that data.
    #
    # @param hash [Hash] the data for which you need a column width
    # @param pad [Integer] the number of spaces you want between columns
    # @return [Integer] length of longest key + pad
    #
    def key_width(hash, pad = 2)
      hash.keys.map(&:size).max + pad
    end

    def indent_wrap(line, cols=78, offset=22)
      #
      # hanging indent long lines to fit in an 80-column terminal
      #
      return unless line
      line.gsub(/(.{1,#{cols - offset}})(\s+|\Z)/, "\\1\n#{' ' *
              offset}").rstrip
    end
  end
end
