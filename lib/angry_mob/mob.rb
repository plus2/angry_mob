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
    def ui; Rioter.ui end

    attr_reader :path, :name, :loader


    def initialize(path,name=nil)
      @path = Pathname(path).expand_path
      @name = name || @path.basename.to_s

      ui.log "added mob #{@name} from #{@path}"
    end


    def load!(loader)
      @loader = loader

      ui.push("loading mob #{name} at path #{path}") do

        mob_root = path

        # Take load directions from `loader_file`
        loader_file = path+'load_mob.rb'

        if loader_file.exist?
          instance_eval(loader_file.read,loader_file.to_s)
        else
          # Otherwise, assume a default layout.
          load_lib(path     + 'lib')
          load_targets(path + 'targets')
          load_acts(path    + 'acts')
        end
      end

      @loaded = true
      self
    end


    def loaded?
      !! @loaded
    end


    #########
    #  API  #
    #########


    # Ensure the mob `name` is loaded before this one.
    def depends_on_mob(name)
      loader.load_mob_named(name)
    end


    # Load all targets under `path`
    def load_targets(path=nil)
      path ||= self.path + 'targets'

      raise "targets path #{path} didn't exist" unless path.exist?
      ui.log "loading targets from #{path}"

      $LOAD_PATH << path
      Pathname.glob(path+'**/*.rb').each do |file|
        require file
      end
    end


    # Add `path` to the load path
    def load_lib(path=nil)
      path ||= self.path + 'lib'

      raise "lib path #{path} didn't exist" unless path.exist?

      ui.log "adding load path #{path}"
      $LOAD_PATH << path
    end


    # Load all acts under `path`
    def load_acts(path=nil)
      path ||= self.path + 'acts'

      raise "acts path #{path} didn't exist" unless path.exist?
      ui.log "loading acts from #{path}"

      Pathname.glob(path+'**/*.rb').each do |file|
        loader.builder.from_file(self,file)
      end
    end


    # Load acts from the file at `path`.
    def load_act_file(path)
      raise "act file at path #{path} didn't exist" unless path.exist?
      ui.log "loading acts from #{path}"

      loader.builder.from_file(self,path)
    end
  end
end
