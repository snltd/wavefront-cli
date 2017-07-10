module WavefrontDisplayPrinter
  #
  # Base class for the two printer classes
  #
  class Base
    attr_reader :out

    # Give it a key-value hash, and it will return the size of the first
    # column to use when formatting that data.
    #
    # @param hash [Hash] the data for which you need a column width
    # @param pad [Integer] the number of spaces you want between columns
    # @return [Integer] length of longest key + pad
    #
    def key_width(hash = {}, pad = 2)
      return 0 if hash.keys.empty?
      hash.keys.map(&:size).max + pad
    end

    def to_s
      out.join("\n")
    end
  end
end
