class AngryMob
  class Target
    class Notify
      def initialize(act)
        @act = act

        @target = nil
        @target_args = nil

        @when   = :later
        @actions = []

        @backtrace = caller
      end

      def later?
        @when == :later
      end

      def inject_actions(args)
        args.actions = @actions
      end

      def call(mob)
        args = Arguments.parse(@target_args)
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
          @target = method
          @target_args = args

        elsif method == :later || method == :now
          @when = method

        else
          @actions << method
        end

        return self
      end

      def inspect
        "#<AM::T::Notify target=#{@target} actions=#{@actions.inspect}>"
      end
    end
  end
end
