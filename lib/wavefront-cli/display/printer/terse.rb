require_relative '../../stdlib/array'

module WavefrontDisplayPrinter
  #
  # Print values which are per-row. The terse listings, primarily
  #
  class Terse
    attr_reader :data, :fmt

    # @param data [Hash] data to display, from a response object
    # @param keys [Array[Symbol]] keys to display, in order
    #
    def initialize(data, keys)
      @data = stringify(data, keys)
      @fmt  = format_string(data, keys)
    end

    def format_string(data, keys)
      keys.map { |k| "%-#{data.longest_value_of(k)}<#{k}>s" }.join('  ')
    end

    def stringify(data, keys)
      data.map { |e| e.tap { keys.each { |k| e[k] = to_string(e[k]) } } }
    end

    def to_string(value)
      if value.is_a?(Array)
        value.join(', ')
      elsif value.is_a?(Map)
        map_to_string(value)
      else
        value
      end
    end

    def map_to_string(value)
      format('%s=%s', value.keys[0], value.values.join(','))
    end

    def to_s
      data.map { |e| format(fmt, e).rstrip }.join("\n")
    end
  end
end
