# Extensions to the String class to help with formatting.
#
class String
  # Fold long command lines. We can't break on a space after an
  # option or it confuses docopt.
  #
  # @param tw [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  #
  def cmd_fold(tw = TW, indent = 10)
    gsub(/(-\w) /, '\\1^').scan_line(tw - 12).join("\n" + ' ' * indent)
                          .tr('^', ' ')
  end

  # Wrapper around #fold()
  #
  # @param tw [Integer] width of terminal, in chars
  # @param indent [Integer] hanging indent of following lines
  # @return [String] folded and indented string
  #
  def opt_fold(tw = TW, indent = 10)
    fold(tw, indent, '  ')
  end

  # Fold long lines with a hanging indent. Originally a special case
  # for option folding, now addded the prefix parameter to make it
  # more general.
  #
  #
  # @param tw [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  # @param prefix [String] prepended to every line
  # @return [String] the folded line
  #
  def fold(tw = TW, indent = 10, prefix = '')
    chunks = scan_line(tw - 8)
    first_line = format("%s%s\n", prefix, chunks.shift)

    return first_line if chunks.empty?

    rest = chunks.join(' ').scan_line(tw - indent - 5).map do |l|
      prefix + ' ' * indent + l
    end

    first_line + rest.join("\n") + "\n"
  end

  # @param width [Integer] length of longest string (width of
  #   terminal less some margin)
  # @return [Array] original string chunked into an array width
  #   elements whose length < width
  #
  def scan_line(width)
    scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/)
  end

  def to_seconds
    begin
      number, unit = match(/^(\d+)([smhdw])$/).captures
    rescue NoMethodError
      raise ArgumentError
    end

    number.to_i * unit_factor(unit.to_sym)
  end

  # How many seconds in the given unit
  # @param unit [Symbol]
  # @return [Integer]
  #
  def unit_factor(unit)
    factors = { s: 1, m: 60, h: 3600, d: 86_400, w: 604_800 }
    factors[unit] || 1
  end

  # Make a camelCase string be snake_case
  # @return [String]
  #
  def to_snake
    self.gsub(/(.)([A-Z])/) { Regexp.last_match[1] + '_' +
                              Regexp.last_match[2].downcase }
  end
end
