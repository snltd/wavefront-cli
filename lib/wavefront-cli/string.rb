# Extensions to the String class to help with formatting.
#
class String
  # Fold long command lines. We can't break on a space inside
  # [square brackets] or it confuses docopt.
  #
  # @param tw [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  #
  def cmd_fold(tw = TW, indent = 10)
    gsub(/\s(?=\w+\])/, '^').scan_line(tw - 8).join("\n" + ' ' * indent)
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
  # rubocop:disable Metrics/AbcSize
  #
  # @param tw [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  # @param prefix [String] prepended to every line
  # @return [String] the folded line
  #
  def fold(tw = TW, indent = 10, prefix = '')
    chunks = self.scan_line(tw - 8)

    line_1 = prefix + chunks.shift + "\n"

    return line_1 if chunks.empty?

    rest = chunks.join(' ').scan_line(tw - indent - 5).map do |l|
      prefix + ' ' * indent + l
    end

    line_1 + rest.join("\n") + "\n"
  end

  # @param width [Integer] length of longest string (width of
  #   terminal less some margin)
  # @return [Array] original string chunked into an array width
  #   elements whose length < width
  #
  def scan_line(width)
    scan(/\S.{0,#{width}}\S(?=\s|$)|\S+/)
  end
end