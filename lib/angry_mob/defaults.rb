class AngryMob
  class Defaults < Hash
    def initialize(hash=nil)
      update(hash) if hash
    end

    def reverse_merge(other)
      replace(other.update(self))
    end

    def node(attrs)
      update(attrs)
    end
  end
end
