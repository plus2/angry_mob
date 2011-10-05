class AngryMob
  module Actor

    def self.included( base )
      base.extend ClassMethods
    end


    module ClassMethods
      def build_instance( options, *arguments )
        if klass = ( @build_block && @build_block[ *arguments ] ) || self
          klass.new
        end

        # XXX use an abstract keyword, to stop instantiating the base class
      end


      # internal API
      def build(&blk)
        @build_block = blk
      end
    end


    # Actors quack like multi-acts, by definition
    def multi?; true end 


    def name
      self.class.name
    end


    def run!(*args)
      args.tapp(:running)
    end


    
  end
end
