class AngryMob
  module Actor

    def self.included( base )
      base.extend ClassMethods
      base.__send__ :include, AngryMob::Act::Api

      base.class_eval do
        attr_reader :rioter
      end
    end


    module ClassMethods
      def build_instance( rioter, options, *arguments )
        if klass = ( @build_block && @build_block[ *arguments ] ) || self
          klass.new(rioter)
        end

        # XXX use an abstract keyword, to stop instantiating the base class
      end


      # internal API
      def build(&blk)
        @build_block = blk
      end
    end


    def initialize(rioter)
      @rioter = rioter
    end


    MMSentinel = %r{angry_mob/act/api.rb:\d+:in `method_missing'}

    def definition_file
      stacktrace = caller(0)

      if index = stacktrace.index {|line| line[MMSentinel]}
        stacktrace[index+1].split(':').first
      else
        "<unknown>"
      end

    end


    # Actors quack like multi-acts, by definition
    def multi?; true end 


    def name
      self.class.name
    end


    def run!(*args)
    end
  end
end
