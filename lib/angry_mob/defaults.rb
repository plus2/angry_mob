class AngryMob
  class Defaults < Hash
    def initialize(hash)
      update(hash)
    end

    def reverse_merge(other)
      replace(other.update(self))
    end
  end
end
