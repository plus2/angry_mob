require 'tsort'

class AngryMob
  class MobLoadingError < StandardError; end

  ::Target = AngryMob::Target

  class MobLoader
    attr_reader :builder, :mobs, :loaded_mobs

    def ui
      Mob.ui
    end

    def initialize
      @builder = Builder.new
      @mobs = Dictionary.new
      @loaded_mobs = {}
    end

    def add_mob(path,name=nil)
      path = Pathname(path).expand_path
      name ||= path.basename.to_s

      mobs[name] ||= path
    end

    def load_a_mob(name)
      path = mobs[name]
      raise "unable to load unknown mob #{name}" unless path

      return if loaded_mobs[name]
      loaded_mobs[name] = true

      old_path,@current_path = @current_path,path

      ui.push("loading mob #{name} at path #{path}") do

        loader = path+'load.rb'

        if loader.exist?
          instance_eval(loader.read,loader.to_s)
        else
          load_lib(path+'lib')
          load_targets(path+'targets')
          load_acts(path+'acts')
        end
      end

      self
    ensure
      @current_path = old_path
    end

    def load_mobs
      mobs.keys.each do |name|
        load_a_mob(name)
      end
    end

    def to_mob
      load_mobs
      @builder.to_mob
    end


    # API
    alias_method :depends_on_mob, :load_a_mob

    def load_targets(path=(@current_path+'targets'))
      raise "targets path #{path} didn't exist" unless path.exist?
      ui.log "loading targets from #{path}"

      $LOAD_PATH << path
      Pathname.glob(path+'**/*.rb').each do |file|
        require file
      end
    end

    def load_lib(path=(@current_path+'lib'))
      raise "lib path #{path} didn't exist" unless path.exist?
      ui.log "adding load path #{path}"
      $LOAD_PATH << path
    end

    def load_acts(path=(@current_path+'acts'))
      raise "acts path #{path} didn't exist" unless path.exist?
      ui.log "loading acts from #{path}"

      Pathname.glob(path+'**/*.rb').each do |file|
        @builder.from_file(file)
      end
    end

  end
end
