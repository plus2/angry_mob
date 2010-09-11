class AngryMob
  class Target
    ## Target Mother
    # Gives birth to target instances.
    #
    # Maps nicknames onto `Target` subclasses and creates memoised `Target::Call`s.
    class Mother
      attr_reader :rioter

      def initialize(rioter)
        @rioter = rioter
      end

      def target_classes
        Target::Tracking.subclasses
      end

      # Allow one class to pose under another's nickname
      def pose_as(nickname,nickname_to_pose_as)
        nickname            = nickname.to_s
        nickname_to_pose_as = nickname_to_pose_as.to_s

        posing_class = target_classes[nickname           ] || raise(TargetError, "posing class '#{nickname}' doesn't exist!")
        old_class    = target_classes[nickname_to_pose_as]

        target_classes[nickname_to_pose_as] = posing_class

        if old_class && instances = key_classes.delete(old_class)
          # TODO - merge instances if required
        end
      end

      # Given a nickname, look up the `Target` subclass and create a memoised `Target::Call`.
      def target_call(nickname, *args, &blk)
        raise(MobError, "no target nicknamed '#{nickname}'\navailable targets:\n#{target_classes.keys.inspect}") unless target_classes.key?(nickname.to_s)

        # Map nickname -> class
        klass = target_classes[nickname.to_s]

        args = Arguments.parse(args,&blk)

        if key = Target::Call.instance_key(klass,args)

          # Use the memoised call if we can.
          if call = target_instances[key]

            # Remember, adding args is subject to `Target::Call`'s semantics.
            call.add_args(args)
          else

            # Create and remember a new call.
            call = target_instances[key] = Target::Call.new( klass, args )
          end

        else
          # Some targets are anonymous or "unkeyed".
          # They can be created but not memoised under a key.
          # We write them to `unkeyed_instances` to keep track of them in some way (even if its to stop them being GC'd)
          unkeyed_instances << call = Target::Call.new( klass, args )

        end

        # If call doesn't already have an instance of the `Target`, make one.
        call.target ||= klass.new

        call
      end

      def clear_instances!
        @target_instances = nil
      end

      def target_instances
        @target_instances ||= {}
      end

      def unkeyed_instances
        @unkeyed_instances ||= []
      end

      def key_classes 
        @key_classes ||= Hash.new {|h,k| h[k] = []}
      end
      
    end
  end
end
