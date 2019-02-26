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
      data.keep_if { |k, _v| fields.include?(k.to_sym) }
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
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def make_list(data, aggr = [], depth = 0, last_key = nil)
      if data.is_a?(Hash)
        data.each_pair do |k, v|
          if v.is_a?(Hash)
            if v.empty? && opts[:none]
              aggr.<< [k, '<none>', depth]
            else
              aggr.<< [k, nil, depth]
              make_list(v, aggr, depth + 1)
            end
          elsif v.is_a?(Array)
            if v.empty? && opts[:none]
              aggr.<< [k, '<none>', depth]
            elsif v.all? { |w| w.is_a?(String) }
              v.sort!
              aggr.<< [k, preened_value(v.shift), depth]
              make_list(v, aggr, depth, k)
            else
              aggr.<< [k, nil, depth]
              make_list(v, aggr, depth + 1, k)
            end
          else
            val = v.to_s.empty? && opts[:none] ? '<none>' : preened_value(v)
            aggr.<< [k, val, depth]
          end
        end
      elsif data.is_a?(Array)
        data.each.with_index(1) do |element, i|
          make_list(element, aggr, depth, last_key)

          if opts[:separator] && element.is_a?(Hash) && i < data.size
            aggr.<< ['', :separator, depth]
          end
        end
      else
        aggr.<< ['', preened_value(data), depth]
      end

      aggr
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength

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
        format('%s%s', key_str, val).rstrip
      end.join("\n")
    end
    # rubocop:enable Metrics/AbcSize
  end
end
