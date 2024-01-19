# frozen_string_literal: true

# Extensions to the String class to help with formatting.
#
class String
  # Fold long command lines. We can't break on a space after an
  # option or it confuses docopt.
  #
  # @param twidth [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  #
  def cmd_fold(twidth = TW, indent = 10)
    gsub(/(-\w) /, '\\1^').scan_line(twidth - 12).join("\n#{' ' * indent}")
                          .restored
  end

  # Wrapper around #fold()
  #
  # @param twidth [Integer] width of terminal, in chars
  # @param indent [Integer] hanging indent of following lines
  # @return [String] folded and indented string
  #
  def opt_fold(twidth = TW, indent = 10)
    fold(twidth, indent, '  ')
  end

  # Fold long lines with a hanging indent. Originally a special case
  # for option folding, now addded the prefix parameter to make it
  # more general. Don't line-break default values, because it also
  # breaks docopt.
  #
  # @param twidth [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  # @param prefix [String] prepended to every line
  # @return [String] the folded line
  #
  def fold(twidth = TW, indent = 10, prefix = '')
    chunks = gsub('default: ', 'default:^').scan_line(twidth - 8)
    first_line = format("%<padding>s%<text>s\n",
                        padding: prefix,
                        text: chunks.shift)

    return first_line.restored if chunks.empty?

    rest = indent_folded_lines(chunks, twidth, indent, prefix)
    (first_line + rest.join("\n")).restored
  end

  # We use a carat as a temporary whitespace character to avoid
  # undesirable line breaking. This puts it back
  #
  def restored
    tr('^', ' ').chomp
  end

  # Fold long value lines in two-column output. The returned string
  # is appended to a key, so the first line is not indented.
  #
  def value_fold(indent = 0, twidth = TW)
    max_line_length = twidth - indent - 4
    scan_line(max_line_length).join("\n#{' ' * indent}")
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
    gsub(/(.)([A-Z])/) do
      "#{Regexp.last_match[1]}_#{Regexp.last_match[2].downcase}"
    end
  end

  private

  def indent_folded_lines(chunks, twidth, indent, prefix)
    chunks.join(' ').scan_line(twidth - indent - 5).map do |line|
      "#{prefix}#{' ' * indent}#{line}"
    end
  end
end
