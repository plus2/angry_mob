require 'tsort'

class AngryMob
  class MobLoadingError < StandardError; end

  # `TargetList` is a hash for topologically sorting target blocks. Thus it provides simple dependency handling.
  class MobList < Hash
    include TSort

    alias_method :tsort_each_node, :each_key
    def tsort_each_child(node, &block)
      fetch(node)[:dependencies].each(&block)
    end

    def add_path(name,path,dependencies)
      dependencies = [ dependencies ].flatten.compact.map {|k| k.to_s}
      self[name.to_s] = {:path => blk, :dependencies => dependencies}
    end

    def each_target(&block)
      each_strongly_connected_component do |name|
        name = name.first
        yield name, fetch(name)[:block]
      end
    end
  end



  class MobLoader
    attr_reader :builder, :mobs, :loaded_mobs

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
      puts "loading mob #{name} at path #{path}"
      raise "unable to load unknown mob #{name}" unless path

      return if loaded_mobs[name]
      loaded_mobs[name] = true

      loader = path+'load.rb'

      if loader.exist?
        instance_eval(loader.read,loader.to_s)
      else
        load_lib(path)
        load_targets(path)
        load_mob(path)
      end

      self
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

    def load_targets(path)
      # XXX
    end

    def load_lib(path)
      $LOAD_PATH << path+'lib'
    end

    def load_mob(path)
      puts "loading mob from #{path}"

      Pathname.glob(path+'mob/**/*.rb').each do |file|
        @builder.from_file(file)
      end
    end

  end
end
