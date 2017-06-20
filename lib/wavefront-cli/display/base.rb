require_relative '../constants'

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
    include WavefrontCli::Constants

    attr_reader :data, :options, :indent, :kw, :indent_str, :indent_step,
                :hide_blank

    # Display classes can provide a do_method_code() method, which
    # handles <code> errors when running do_method()
    #
    def run_error(method)
      return unless respond_to?(method)
      send(method)
      exit 1
    end

    def initialize(data, options = {})
      @data = data
      @options = options
      @indent = 0
      @indent_step = options[:indent_step] || 2
      @hide_blank = options[:hide_blank] || true
    end

    def run(method)
      if method == 'do_list'
        if options[:long]
          do_list
        else
          do_list_brief
        end

        return
      end

      if respond_to?("#{method}_brief")
        send("#{method}_brief")
      elsif respond_to?(method)
        send(method)
      else
        long_output
      end
    end

    def long_output(fields = nil, modified_data = nil)
      _two_columns(modified_data || data, nil, fields)
    end

    # Extract two fields from a hash and print a list of them as
    # pairs.
    #
    # @param col1 [String] the field to use in the first column
    # @param col2 [String] the field to use in the second column
    # @return [Nil]
    #
    def terse_output(col1 = :id, col2 = :name, modified_data = nil)
      d = modified_data || data
      want = d.each_with_object({}) { |r, a| a[r[col1]] = r[col2] }
      @indent_str = ''
      @kw = key_width(want)

      want.each do |k, v|
        v = v.join(', ') if v.is_a?(Array)
        print_line(k, v)
      end
    end

    # Print multiple column output. Currently this method does no
    # word wrapping.
    #
    # @param keys [Symbol] the keys you want in the output. They
    #   will be printed in the order given.
    #
    def multicolumn(*keys)
      len = Hash[*keys.map {|k| [k, 0]}.flatten]

      keys.each do |k|
        data.each do |obj|
          val = obj[k]
          val = val.join(', ') if val.is_a?(Array)
          len[k] = val.size if val.size > len[k]
        end
      end

      fmt = keys.each_with_object('') { |k, out| out.<< "%-#{len[k]}s  " }

      data.each do |obj|
        args = keys.map do |k|
          obj[k].is_a?(Array) ? obj[k].join(', ') : obj[k]
        end

        puts format(fmt, *args)
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
          next if v.respond_to?(:empty?) && v.empty? && hide_blank

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
          print_line(k) if i.zero?
          @indent += indent_step
          @kw -= 2
          _two_columns([w], kw - indent_step)
          print_line('', '---') unless i == v.size - 1
        else
          if i.zero?
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
      if key.empty?
        puts ' ' * kw + value
      else
        puts indent_str + format("%-#{kw}s%s", key, value).fold(TW, kw)
      end
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

    def indent_wrap(line, cols = 78, offset = 22)
      #
      # hanging indent long lines to fit in an 80-column terminal
      #
      return unless line
      line.gsub(/(.{1,#{cols - offset}})(\s+|\Z)/, "\\1\n#{' ' *
              offset}").rstrip
    end

    def friendly_name
      self.class.name.split('::').last.gsub(/([a-z])([A-Z])/, '\\1 \\2')
          .downcase
    end

    def do_list
      long_output
    end

    def do_list_brief
      terse_output
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
    #
    def drop_fields(*keys)
      data.delete_if { |k, _v| keys.include?(k.to_sym) }
    end

    # Modify, in-place, the data structure to make times
    # human-readable. Automatically handles second and millisecond
    # epoch times.
    #
    def readable_time(*keys)
      keys.each do |k|
        next unless data.key?(k)
        data[k] = human_time(data[k])
      end
    end

    def human_time(t)
      str = t.to_s

      if str.length == 13
        fmt = '%Q'
        out_fmt = HUMAN_TIME_FORMAT_MS
      else
        fmt = '%s'
        out_fmt = HUMAN_TIME_FORMAT
      end

      DateTime.strptime(str, fmt).strftime(out_fmt)
    end

  end
end

# Extensions to the String class to help with formatting.
#
class String

  # Fold long command lines and suitably indent
  #
  def fold(width = TW, indent = 10)
    scan(/\S.{0,#{width - 2}}\S(?=\s|$)|\S+/).join("\n" + ' ' * indent)
  end
end
