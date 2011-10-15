class AngryMob
  module Actor

    def self.included( base )
      base.extend ClassMethods
      base.__send__ :include, AngryMob::Act::Api

      path, = caller[0].partition(":")     
      base.definition_file = path

    end


    module ClassMethods
      def inherited(klass)
        super
        path, = caller[0].partition(":")
        klass.definition_file = path
      end


      def definition_file=(definition_file)
        @definition_file = definition_file
      end


      def definition_file; @definition_file end


      def abstract_actor
      end


      # XXX pass in anything?
      def build_instance( node, options, *arguments )
        if klass = ( @build_block && @build_block[ *arguments ] ) || self
          klass.new(node)
        end

        # XXX use an abstract keyword, to stop instantiating the base class
      end


      # internal API
      def build(&blk)
        @build_block = blk
      end
    end


    # XXX global :(
    def ui; Rioter.ui end


    def initialize(node)
      @node = node
    end


    #MMSentinel = %r{angry_mob/act/api.rb:\d+:in `method_missing'}

    ## XXX handle ancestor chain, for resource locator search path
    #def definition_file
      #stacktrace = caller(0).tapp

      #if index = stacktrace.index {|line| line[MMSentinel]}
        #stacktrace[index+1].split(':').first
      #else
        #"<unknown>"
      #end

    #end

    def definition_file; self.class.definition_file end


    # Actors quack like multi-acts, by definition
    def multi?; true end 


    def name
      self.class.name
    end


    def run!(node, *args)
    end
  end
end
