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

      def target_call
        # XXX seems like the wrong place for all this...
        args = ( @target_args || [] ).dup
        options = args.options

        @mob.target(@target,*args)
      end

      def call(*)
        # localise to save into closure
        target,target_args,actions = @target,@target_args,@actions

        # this block is instance_eval'd
        @act.in_sub_act do
          target = send(target, (target_args || []).dup)
          actions.norm.each {|action| target.send(action)}
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
