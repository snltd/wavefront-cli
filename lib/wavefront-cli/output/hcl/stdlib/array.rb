#
# Extensions to stdlib Array
#
class Array
  #
  # Turn an array into a string which represents an HCL list
  # @return [String]
  #
  def to_hcl_list
    '[' + join(',') + ']'
  end

  # Turn an array into a string which represents an HCL object
  # @return [String]
  #
  def to_hcl_obj(indent = 0)
    outpad = ' ' * indent
    inpad = ' ' * (indent + 2)

    "\n#{outpad}{\n#{inpad}" + join("\n#{inpad}") + "\n#{outpad}}"
  end
end
