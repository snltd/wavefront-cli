require_relative './base'

module WavefrontDisplayPrinter

  # Print things which are per-row. The terse listings, primarily
  #
  class Terse < Base
    attr_reader :data, :keys, :fmt_string

    def initialize(data, *keys)
      # require 'json'
      # File.open('/tmp/1', 'w') { |f| f.puts data.to_json }
      @data = data
      @keys = keys
      @fmt_string = format_string.rstrip
      @out = prep_output
    end

    # @return [String] a Ruby format string for each line
    #
    def format_string
      lk = longest_keys
      keys.each_with_object('') { |k, out| out.<< "%-#{lk[k]}s  " }
    end

    # Find the length of the longest value for each member of @keys,
    # in @data.
    #
    # @return [Hash] with the same keys as :keys and Integer values
    #
    def longest_keys
      keys.each_with_object(Hash[*keys.map { |k| [k, 0] }.flatten]) \
      do |k, aggr|
        data.each do |obj|
          val = obj[k]
          val = val.join(', ') if val.is_a?(Array)
          aggr[k] = val.size if val.size > aggr[k]
        end
      end
    end

    # Print multiple column output. This method does no word
    # wrapping.
    #
    # @param keys [Symbol] the keys you want in the output. They
    #   will be printed in the order given.
    #
    def prep_output
      data.each_with_object([]) do |o, aggr|
        args = keys.map { |k| o[k].is_a?(Array) ? o[k].join(', ') : o[k] }
        aggr.<< format(fmt_string, *args).rstrip
      end
    end
  end
end
