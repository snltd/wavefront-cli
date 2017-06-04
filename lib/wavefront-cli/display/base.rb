module WavefrontDisplay
  #
  # Print human-friendly output. If a command requires a dedicated
  # handler to format its output, define a method with the same name
  # as that which fetches the data, in a WavefrontDisplay class,
  # extending this one.
  #
  # We provide long_output() and terse_output() methods to solve
  # standard formatting problems. To use them, define a do_() method
  # but rather than printing the output, have it call the method.
  #
  class Base
    attr_reader :data, :options, :indent, :kw, :indent_str, :indent_step,
                :hide_blank

    def initialize(data, method, options = {})
      @data = data
      @options = options
      @indent = 0
      @indent_step = options[:indent_step] || 2
      @hide_blank = options[:hide_blank] || true

      if options[:long] && self.respond_to?(method)
        send(method)
      elsif options[:long]
        long_output
      elsif self.respond_to?("#{method}_brief")
        send("#{method}_brief")
      else
        terse_output
      end
    end

    def long_output(fields = nil)
      _two_columns(data, nil, fields)
    end

    # Extract two fields from a hash and print a list of them as
    # pairs.
    #
    # @param col1 [String] the field to use in the first column
    # @param col2 [String] the field to use in the second column
    # @return [Nil]
    #
    def terse_output(col1 = :id, col2 = :name)
      want = data.each_with_object({}) { |r, a| a[r[col1]] = r[col2] }
      @indent_str = ''
      @kw = key_width(want)

      want.each do |k, v|
        v = v.join(', ') if v.is_a?(Array)
        print_line(k, v)
      end
    end

    def set_indent(indent)
      @indent_str = ' ' * indent
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
      [data].flatten.each do |row|
        row.keep_if { |k, _v| fields.include?(k) } unless fields.nil?
        kw = key_width(row) unless kw
        @kw = kw unless @kw
        set_indent(indent)

        row.each do |k, v|
          next if (v.is_a?(String) || v.is_a?(Array)) && v.empty? &&
                  hide_blank

          if v.is_a?(String) && v.match(/<.*>/)
            v = v.gsub(%r{<\/?[^>]*>}, '').delete("\n")
          end

          if v.is_a?(Hash)
            print_line(k)
            @indent += indent_step
            @kw -= 2
            _two_columns([v], kw - indent_step)
          elsif v.is_a?(Array)
            print_array(k, v)
          else
            print_line(k, v)
          end
        end
        puts if indent.zero?
      end

      @indent -= indent_step if indent > 0
      @kw += 2
      set_indent(indent)
    end

    def print_array(k, v)
      v.each_with_index do |w, i|
        if w.is_a?(Hash)
          print_line(k) if i == 0
          @indent += indent_step
          @kw -= 2
          _two_columns([w], kw - indent_step)
          print_line('', "---") unless i == v.size - 1
        else
          if i == 0
            print_line(k, v.shift)
          else
            print_line('', w)
          end
        end
      end
    end

    # Print a single line of output
    # @param key [String] what to print in the first (key) column
    # @param val [String, Numeric] what to print in the second column
    # @param indent [Integer] number of leading spaces on line
    #
    def print_line(key, value = '')
      puts format("%s%-#{kw}s%s", indent_str, key, value)
    end

    # Give it a key-value hash, and it will return the size of the first
    # column to use when formatting that data.
    #
    # @param hash [Hash] the data for which you need a column width
    # @param pad [Integer] the number of spaces you want between columns
    # @return [Integer] length of longest key + pad
    #
    def key_width(hash, pad = 2)
      return 0 if hash.keys.empty?
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

    def do_tag_add
      puts "Added tag."
    end

    def do_tag_delete
      puts "Deleted tag."
    end

    def do_tag_clear
      puts "Cleared tags on #{options[:'<id>']}."
    end

    def do_tag_set
      puts "Set tags."
    end

    def do_tags
      if data.empty?
        puts "No tags set on #{options[:'<id>']}."
      else
        data.sort.each { |t| puts t }
      end
    end
  end
end
