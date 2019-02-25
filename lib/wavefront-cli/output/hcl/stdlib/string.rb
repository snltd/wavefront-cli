#
# Extensions to stdlib String
#
class String
  def braced(indent = 0)
    pad = ' ' * indent
    "\n#{pad}{#{self}\n#{pad}}"
  end
end
