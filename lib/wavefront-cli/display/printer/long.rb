module WavefrontDisplayPrinter
  #
  # Print the long indented descriptions of things
  #
  class Long
    attr_reader :opts, :list, :kw
    #
    # @param data [Hash] of data to display
    # @param fields [Array[Symbol]] requred fields
    # @param modified_data [Hash] an override for @data
    # @param options [Hash] keys can be
    #   indent:    [Integer] by how many spaces nested objects should indent
    #   padding:   [Integer] number of spaces between columns
    #   separator: [Bool] whether or not to print a line of dashes
    #              between objects in an array of objects
    #   none       [Bool] whether or not to put '<none>' for empty arrays
    #
    def initialize(data, fields = nil, modified_data = nil, options = {})
      @opts = default_opts.merge(options)
      data  = preened_data(data, fields)
      @list = make_list(modified_data || data)
      @kw   = longest_key_col(list)
    end

    # Default options. Can all be overridden by passing them in the
    # initializer options hash.
    #
    def default_opts
      { indent:    2,
        padding:   2,
        separator: true,
        none:      true }
    end

    # @param data [Hash] raw data
    # @param fields [Array, Nil] fields to keep in @data. Nil means
    #   everything
    # @return [Hash]
    #
    def preened_data(data, fields = nil)
      return data if fields.nil?
      data.map { |d| d.select { |k| fields.include?(k.to_sym) }.to_h }
    end

    # Remove HTML and stuff
    #
    # @param [String] raw value
    # @return [String] value with all HTML stripped out
    #
    def preened_value(value)
      return value unless value.is_a?(String) && value =~ /<.*>/
      value.gsub(%r{<\/?[^>]*>}, '').delete("\n")
    end

    # A recursive function which takes a structure, most likely a
    # hash, and turns it into an array of arrays. This output is
    # easily formatted into nicely laid-out columns by #to_s. Most of
    # the parameters are used by the function itself.
    # @param data [Object] the thing you wish to present
    # @param aggr [Array] aggregates the output array. Don't set this
    #   yourself
    # @param depth [Integer] how many layers of indentation are
    #   required. Don't set this yourself.
    # @param last_key [String, Nil] a memo used for printing arrays.
    #   Don't set this yourself.
    # @return [Array[Array]] where each sub-array is of the form
    #   [key, value, depth]
    #
    # Make an array of hashes: { key, value, depth }
    #
    def make_list(data, aggr = [], depth = 0, last_key = nil)
      if data.is_a?(Hash)
        append_hash(data, aggr, depth)
      elsif data.is_a?(Array)
        append_array(data, aggr, depth, last_key)
      else
        aggr.<< ['', preened_value(data), depth]
      end
    end

    def smart_value(val)
      val.to_s.empty? && opts[:none] ? '<none>' : preened_value(val)
    end

    # Works out what the width of the left-hand (key) column needs to
    # be. This considers indentation and padding.
    # @param data [Array] of the form returned by #make_list
    # @return [Integer]
    #
    def longest_key_col(data)
      data.map { |d| d[0].size + opts[:padding] + opts[:indent] * d[2] }.max
    end

    # Turn the list made by #make_list into user output
    # @return [String]
    #
    # rubocop:disable Metrics/AbcSize
    def to_s
      list.map do |e|
        indent = ' ' * opts[:indent] * e.last
        key_str = (indent + e.first.to_s + '  ' * kw)[0..kw]
        val = e[1] == :separator ? '-' * (TW - key_str.length) : e[1]
        line(key_str, val)
      end.join("\n")
    end
    # rubocop:enable Metrics/AbcSize

    def line(key, val)
      line_length = key.to_s.size + val.to_s.size

      if line_length > TW && val.is_a?(String)
        val = val.value_fold(key.to_s.size)
      end

      format('%s%s', key, val).rstrip
    end

    private

    # Part of the #make_list recursion. Deals with a hash.
    #
    # @param data [Hash]
    # @param aggr [Array[Array]]
    # @param depth [Integer]
    # @return [Array[Array]]
    #
    def append_hash(data, aggr, depth)
      data.each_pair do |k, v|
        if v.is_a?(Hash)
          aggr = append_hash_values(k, v, aggr, depth)
        elsif v.is_a?(Array)
          aggr = append_array_values(k, v, aggr, depth)
        else
          aggr.<< [k, smart_value(v), depth]
        end
      end

      aggr
    end

    # Part of the #make_list recursion. Deals with arrays.
    #
    # @param data [Array]
    # @param aggr [Array[Array]]
    # @param depth [Integer]
    # @return [Array[Array]]
    #
    def append_array(data, aggr, depth, last_key)
      data.each.with_index(1) do |element, i|
        aggr = make_list(element, aggr, depth, last_key)

        if opts[:separator] && element.is_a?(Hash) && i < data.size
          aggr.<< ['', :separator, depth]
        end
      end

      aggr
    end

    # Part of the #make_list recursion. Appends the key name of a
    # hash. May be paired with '<none>' if the hash is empty,
    # otherwise indent another level and go back into the recursive
    # loop with the values.
    #
    # @param key [String] key of hash
    # @param values [Hash] values of hash
    # @param depth [Integer]
    # @return [Array[Array]]
    #
    def append_hash_values(key, values, aggr, depth)
      if values.empty? && opts[:none]
        aggr.<< [key, '<none>', depth]
      else
        aggr.<< [key, nil, depth]
        make_list(values, aggr, depth + 1)
      end
    end

    # Part of the #make_list recursion.
    #
    # @param data [Hash]
    # @param aggr [Array[Array]]
    # @param depth [Integer]
    # @return [Array[Array]]
    #
    def append_array_values(key, values, aggr, depth)
      if values.empty? && opts[:none]
        aggr.<< [key, '<none>', depth]
      elsif values.all? { |w| w.is_a?(String) }
        values.sort!
        aggr.<< [key, preened_value(values.shift), depth]
        make_list(values, aggr, depth, key)
      else
        aggr.<< [key, nil, depth]
        make_list(values, aggr, depth + 1, key)
      end
    end
  end
end
