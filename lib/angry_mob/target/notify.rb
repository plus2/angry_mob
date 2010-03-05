class AngryMob
  class Target
    class Notify
      def initialize(mob)
        @mob = mob

        @target = nil
        @target_args = nil

        @when   = :later
        @actions = []
      end

      def later?
        @when == :later
      end

      def target_call
        # XXX seems like the wrong place for all this...
        args = ( @target_args || [] ).dup
        options = args.options

        all_actions = options.delete_all_of(:actions,:action)

        options.update(:actions => [ all_actions, @actions ].flatten.compact.uniq)

        @mob.target(@target,*args)
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
    end
  end
end
