# frozen_string_literal: true

require 'map'
require_relative '../../stdlib/array'

module WavefrontDisplayPrinter
  #
  # Print values which are per-row. The terse listings, primarily
  #
  class Terse
    attr_reader :data

    # @param data [Hash] data to display, from a response object
    # @param keys [Array[Symbol]] keys to display, in order
    #
    def initialize(data, keys)
      @data = stringify(data, keys)
      @fmt  = format_string(data, keys)
    end

    # @return [String] used to format output
    #
    def format_string(data, keys)
      keys.map { |k| "%-#{data.longest_value_of(k)}<#{k}>s" }.join('  ')
    end

    # Flatten nested data.
    # @param data [Map,Hash] data to flatten
    # @param keys [Array[Symbol]] keys of interest. We don't bother working on
    #   things we'll only throw away
    #
    def stringify(data, keys)
      data.map { |e| e.tap { keys.each { |k| e[k] = value_as_string(e[k]) } } }
    end

    # Turn a (potentially) more complicated structure into a string
    # @param value [Object]
    # @return [String]
    #
    def value_as_string(value)
      return value.join(', ') if value.is_a?(Array)
      return map_to_string(value) if value.is_a?(Map)
      value
    end

    # If we get a hash as a value (tags, for instance) we squash it down to a
    # "key1=val1;key2=val2" kind of string. Note that this doesn't handle
    # nested hashes. It shouldn't have to.
    #
    # @param value [Map,Hash] { k1: 'v1', k2: 'v2' }
    # @return [String] 'k1=v1;k2=v2'
    #
    def map_to_string(value)
      value.map { |k, v| "#{k}=#{v}" }.join(';')
    end

    # Format every element according to the format string @fmt
    #
    def to_s
      data.map { |e| format(@fmt, e).rstrip }.join("\n")
    rescue KeyError
      raise WavefrontCli::Exception::UserError, 'field not found'
    end
  end
end
