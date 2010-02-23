require 'pathname'

class String
  def pathname
    Pathname(self)
  end
  alias_method :p, :pathname
end
