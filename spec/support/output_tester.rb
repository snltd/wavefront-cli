require 'json'
require_relative '../constants'

# We keep a bunch of Wavefront API responses as text files alongside
# canned responses in various formats. This class groups helpers for
# consuming those files.
#
class OutputTester
  # @param file [String] filename to load
  # @param only_items [Bool] true for the items hash, false for the
  #   whole loadedobject
  # @return [Object] canned raw responses used to test outputs
  #
  def load_input(file, only_items = true)
    ret = JSON.parse(IO.read(RES_DIR + 'display' + file),
                     symbolize_names: true)
    only_items ? ret[:items] : ret
  end

  # @param file [String] file to load
  # @return [String]
  #
  def load_expected(file)
    IO.read(RES_DIR + 'display' + file)
  end

  def in_and_out(input, expected, only_items = true)
    [load_input(input, only_items), load_expected(expected)]
  end
end