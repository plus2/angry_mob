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

      # TODO XXX abstract arguments into new class, for easy manipulation ffs
      def inject_actions
        args = @target_args ||= []

        if Hash === args.last
          opts = args[-1] = AngryHash.__convert_without_dup(args.last)
        else 
          args << opts = AngryHash.new
        end

        opts.delete('action')
        opts.actions = @actions

        args.tapp
      end

      def call(*)
        inject_actions
        
        # localise to save into closure
        target,target_args,actions = @target,@target_args,@actions

        # this block is instance_eval'd
        @act.in_sub_act do
          send(target.tapp(:tgt), *(target_args || []).dup.tapp(:args))
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
