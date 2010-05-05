class AngryMob
  class Action
    def initialize(name,default=false)
      @default = default
    end

    def default?
      !!@default
    end
  end
end
