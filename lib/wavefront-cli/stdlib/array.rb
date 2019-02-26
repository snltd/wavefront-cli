# Extensions to stdlib's Array
#
class Array
  # @return [Integer] the length of the longest string or symbol in
  #   an array
  #
  def max_length
    return 0 if empty?
    map(&:to_s).map(&:length).max
  end

  # @return [Integer] the length of the longest value in an array of
  #   hashes with the given key
  #
  # @param key [String, Symbol] key to search for
  #
  def longest_value_of(key)
    map { |v| v[key] }.max_length
  end
end
