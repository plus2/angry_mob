class AngryMob
  module Actor

    def self.included( base )
      base.extend ClassMethods
      base.__send__ :include, AngryMob::Act::Api

      base.class_eval do
      end
    end


    module ClassMethods
      # XXX pass in anything?
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


    def initialize
    end


    MMSentinel = %r{angry_mob/act/api.rb:\d+:in `method_missing'}

    # XXX handle ancestor chain, for resource locator search path
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


    def run!(node, *args)
    end
  end
end
