class AngryMob
  class NullMob
    def ui ; Rioter.ui end
    def name; 'nullmob' end
  end


  ## Mob
  # A collection of acts, targets and supporting libraries.
  #
  # TODO add different kinds of mobs: path, gem, git
  class Mob
    autoload :Builder, "angry_mob/mob/builder"


    # delegate
    def ui; Rioter.ui end


    attr_reader :path, :dependencies, :builder


    def initialize(path)
      @path = Pathname(path).expand_path

      @dependencies = []

      ui.log "added mob from #{@path}"
    end


    def load!
      ui.push("loading mob at path #{ path }") do
        # Take load directions from `loader_file`
        loader_file = path+'load_mob.rb'

        instance_eval(loader_file.read, loader_file.to_s)

        validate!
      end

      ui.good "loaded mob #{ name }"

      @loaded = true
      self
    end
    


    def loaded?
      !! @loaded
    end


    def validate!
      @name or raise "no name"
    end


    def build!(attributes)
      # XXX setup context
      @builder = Builder.new(self, attributes)
      @builder.build_mob!(@build_block)
      @builder
    end


    def built?
      !! @builder
    end


    #########
    #  API  #
    #########

    def name(name=nil)
      if name
        @name = name
      end

      @name
    end


    def build(&blk)
      @build_block = blk
    end


    # Ensure the mob `name` is loaded before this one.
    def depends_on_mob(name, options={})
      @dependencies << [name, options]
    end

  end
end
