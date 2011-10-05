require 'tsort'

class AngryMob
  class MobLoadingError < StandardError; end

  ::Target = AngryMob::Target

  class MobLoader
    attr_reader :builder, :mobs, :loaded_mobs

    def ui
      Rioter.ui
    end


    def initialize(attributes)
      @builder = Builder.new(attributes)
      @mobs    = Dictionary.new
      @loaded_mobs = {}
    end

    
    def add_mob(path,name=nil)
      Mob.new(path,name).tap {|mob|
        mobs[mob.name] = mob
      }
    end


    def load_mobs
      mobs.each_key do |name|
        load_mob_named(name)
      end
    end


    def load_mob_named(name)
      name = name.to_s
      mob  = mobs[name]

      raise "unable to load unknown mob '#{name}'" unless mob

      return if mob.loaded?

      mob.load!(self)
    end


    def to_rioter
      load_mobs
      builder.to_rioter
    end
  end
end
