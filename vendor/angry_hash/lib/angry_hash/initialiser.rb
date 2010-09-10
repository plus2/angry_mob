class AngryHash
  module Initialiser
    def [](other=nil)
      if other
        super(__convert(other))
      else
        new
      end
    end
  end
end
