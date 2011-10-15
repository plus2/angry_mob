require 'tsort'

class AngryMob
  class MobLoadingError < StandardError; end

  ::Target = AngryMob::Target

  class MobLoader
    attr_reader :mobs, :loaded_mobs, :attributes

    def ui
      Rioter.ui
    end


    def initialize(attributes)
      @attributes   = attributes
      @mobs         = {}
      @mob_order    = []
      @loaded_mobs  = {}
    end

    
    def add_mob(path)
      mob = Mob.new(path)
      mob.load!

      mob_name = mob.name.to_s

      if mobs[ mob_name ]
        raise MobLoadingError, "Already loaded my called '#{ mob_name }'"
      end
      

      mobs[ mob_name ] = mob
      @mob_order << mob
    end


    def build_mobs
      @mob_order.map {|mob| build_mob mob}
    end


    def build_mob(mob)
      ui.push "setting up mob '#{ mob.name }'" do

        if mob.dependencies.present?
          ui.info "loading dependencies"
          mob.dependencies.each do |name, options|
            build_mob_named name, options
          end
        end

        ui.info "setting up"
        mob.build!(attributes)
      end
    end



    def build_mob_named(name, options)
      name = name.to_s
      mob  = mobs[name]

      raise "unable to build unknown mob '#{name}'" unless mob

      return if mob.built?

      build_mob( mob )
    end


    def to_rioter
      build_mobs

      rioter = Rioter.new

      @mob_order.each do |mob|
        mob.builder.add_to_rioter(rioter)
      end

      rioter
    end
  end
end
