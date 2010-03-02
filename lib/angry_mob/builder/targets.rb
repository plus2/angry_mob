class AngryMob
  class Builder
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
      
      def method_missing(method,*args,&blk)
        if args.size == 1
          add_class(args.first, @mob.target_classes[method], &blk)
        else
          super
        end
      end

      protected
      def add_class(nickname,superclass,&blk)
        klass = @mob.target_classes[nickname] = Class.new(superclass, &blk)
        if h = @helpers
          klass.module_eval {
            @nickname = nickname
            include h
          }
        end
      end
    end
  end
end
