class AngryMob
  class NullMob
    def ui
      Rioter.ui
    end
  end

  # TODO add different kinds of mobs: path, gem, git
  class Mob
    def ui
      Rioter.ui
    end

    attr_reader :path, :name, :loader

    def initialize(path,name)
      @path   = Pathname(path).expand_path
      @name ||= @path.basename.to_s

      ui.log "added mob #{@name} from #{@path}"
    end

    def load!(loader)
      @loader = loader

      ui.push("loading mob #{name} at path #{path}") do

        mob_root = path

        loader_file = path+'load_mob.rb'

        if loader_file.exist?
          instance_eval(loader_file.read,loader_file.to_s)
        else
          load_lib(path    +'lib')
          load_targets(path+'targets')
          load_acts(path   +'acts')
        end
      end

      @loaded = true
      self
    end

    def loaded?
      !! @loaded
    end

    # API

    def depends_on_mob(name)
      loader.load_mob_named(name)
    end

    def load_targets(path=nil)
      path ||= self.path + 'targets'

      raise "targets path #{path} didn't exist" unless path.exist?
      ui.log "loading targets from #{path}"

      $LOAD_PATH << path
      Pathname.glob(path+'**/*.rb').each do |file|
        require file
      end
    end

    def load_lib(path=nil)
      path ||= self.path + 'lib'

      raise "lib path #{path} didn't exist" unless path.exist?

      ui.log "adding load path #{path}"
      $LOAD_PATH << path
    end

    def load_acts(path=nil)
      path ||= self.path + 'acts'

      raise "acts path #{path} didn't exist" unless path.exist?
      ui.log "loading acts from #{path}"

      Pathname.glob(path+'**/*.rb').each do |file|
        loader.builder.from_file(self,file)
      end
    end

    def load_act_file(path)
      raise "act file at path #{path} didn't exist" unless path.exist?
      ui.log "loading acts from #{path}"

      loader.builder.from_file(self,path)
    end
  end
end
