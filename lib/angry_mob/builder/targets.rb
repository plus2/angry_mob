class AngryMob
  class Builder
    # `Builder::Targets` provides the interface for defining `Target` subclasses.
    class Targets
      def initialize(name,options={},&blk)
        @dependencies = options[:requires] || []
        @name = name
        @blk  = blk
      end

      def bind(mob)
        @mob = mob
        instance_eval(&@blk)
        self
      end

      #### Definition helpers.

      def TargetHelpers(&blk)
        @helpers ||= Module.new
        @helpers.module_eval(&blk)
      end

      def SingletonTarget(nickname,&blk)
        add_class(nickname,SingletonTarget,&blk)
      end

      def Target(nickname,&blk)
        add_class(nickname,Target,&blk)
      end
      
      # subclass an existing target by name.
      def method_missing(method,*args,&blk)
        if args.size == 1
          add_class(args.first, @mob.target_classes[method], &blk)
        else
          super
        end
      end

      protected
      def add_class(nickname,superclass,&blk)
        # TODO disallow duplicate definition
        klass = @mob.target_classes[nickname.to_sym] = Class.new(superclass, &blk)
        h = @helpers

        klass.module_eval {
          @nickname = nickname.to_sym
          include h if h
        }
      end
    end
  end
end
