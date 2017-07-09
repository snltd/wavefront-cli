# Extensions to the String class to help with formatting.
#
class String
  # Fold long command lines. We can't break on a space inside
  # [square brackets] or it confuses docopt.
  #
  def cmd_fold(width = TW, indent = 10)
    gsub(/\s(?=\w+\])/, '^')
      .scan(/\S.{0,#{width - 8}}\S(?=\s|$)|\S+/).join("\n" + ' ' * indent)
      .tr('^', ' ')
  end

  # Fold long lines with a hanging indent. Originally a special case
  # for option folding, now addded the lead parameter to make it
  # more general.
  #
  # rubocop:disable Metrics/AbcSize
  #
  # @param width [Integer] terminal width
  # @param indent [Integer] size of hanging indent, in chars
  # @param lead [String] prepended to every line
  #
  def fold(width = TW, indent = 10, lead = '  ')
    bits = scan(/\S.{0,#{width - 8}}\S(?=\s|$)|\S+/)

    return lead + bits.first + "\n" if bits.size == 1

    opt_line = bits.shift
    rest = bits.join(' ').scan(/\S.{0,#{width - indent - 5}}\S(?=\s|$)|\S+/)
    lead + opt_line + "\n" + rest.map do |l|
      ' ' * (2 + indent) + l
    end.join("\n") + "\n"
  end
end
