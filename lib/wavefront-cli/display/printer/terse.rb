require_relative '../../stdlib/array'

module WavefrontDisplayPrinter
  #
  # Print things which are per-row. The terse listings, primarily
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
      data.map { |e| e.tap { keys.each { |k| e[k] = to_list(e[k]) } } }
    end

    def to_list(thing)
      thing.is_a?(Array) ? thing.join(', ') : thing
    end

    def to_s
      data.map { |e| format(fmt, e).rstrip }.join("\n")
    end
  end
end
