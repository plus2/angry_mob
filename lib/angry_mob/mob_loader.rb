class AngryMob
  class MobLoadingError < StandardError; end
  class MobLoader
    include Log

    attr_reader :builder

    def initialize
      @builder = Builder.new
    end

    def load(path)
      path = Pathname(path).expand_path

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

    def load_targets(path)
      # XXX
    end

    def load_lib(path)
      $LOAD_PATH << path+'lib'
    end

    def load_mob(path)
      log "loading mob from #{path}"

      Pathname.glob(path+'mob/**/*.rb').each do |file|
        @builder.from_file(file)
      end
    end

    def to_mob
      @builder.to_mob
    end
  end
end
