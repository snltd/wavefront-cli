# The Unicode characters which we use to make a sparkline
#
BLOCKS = [' ', "\u2581", "\u2582", "\u2583", "\u2585", "\u2586",
          "\u2587", "\u2588"].freeze

# How long the sparkline should be
#
SPARK_WIDTH = TW - 20

# A class to create very simple single-row sparklines of a Wavefront
# result.
#
class WavefrontSparkline
  attr_reader :sparkline

  def initialize(series)
    @sparkline = '>' + generate_sparkline(series) + '<'
  end

  # @return [String] the block corresponding to the given value in
  #   the given range. The `rescue` clause handles occasions when
  #   Wavefront returns NaN as a value, or if the range is zero.
  #
  def sized_block(val, range)
    BLOCKS[(val / range * (BLOCKS.length - 1)).floor]
  rescue StandardError
    BLOCKS.first
  end

  # A recursive function which repeatedly halves a data series until
  # it fits inside SPARK_WIDTH characters. It does this by merging
  # adjacent pairs and finding the mean. This is crude.
  # @param vals [Array] a series of values to display
  # @return [Array]
  #
  def make_fit(vals)
    return vals if vals.size < SPARK_WIDTH
    vals.<< vals.last if vals.size.odd?
    ret = vals.each_slice(2).with_object([]) { |s, a| a.<< s.inject(:+) / 2 }
    make_fit(ret)
  end

  # @param data [Array] a series of [time, value] data points
  # @return [String] the sparkline itself
  #
  def generate_sparkline(data)
    values = data.map { |_k, v| v }
    max = values.max || 0
    min = values.min || 0
    v_range = max - min
    values = make_fit(values)
    values.map { |v| sized_block(v - min, v_range) }.join
  end
end
