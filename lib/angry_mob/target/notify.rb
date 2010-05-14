class AngryMob
  class Target
    class Notify
      attr_reader :target, :args, :actions
      def nickname; @target end

      def initialize(act)
        @act = act

        @target = nil
        @args = AngryHash.new

        @actions = []

        @backtrace = caller
      end

      def inject_actions(args)
        args.actions = @actions
      end

      def call(mob)
        raise "not used anymore"
        args = Arguments.parse(@args)
        inject_actions(args)
        
        # localise to save into closure
        target = @target

        # this block is instance_eval'd
        @act.in_sub_act do
          send(target, args)
        end
      end

      def method_missing(method,*args,&blk)
        if ! @target
          @target = method.to_s
          @args = AngryHash.__convert_without_dup( args.first ) if args.first
        end

        if method == :now
          raise "notify.now is no longer supported"

        else
          @actions << method.to_s
        end

        return self
      end

      def inspect
        "#<AM::T::Notify target=#{@target} actions=#{@actions.inspect}>"
      end
    end
  end
end
