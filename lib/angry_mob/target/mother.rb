class AngryMob
  class Target
    ## Target Mother
    # Gives birth to target instances.
    #
    # Maps a nickname onto a `Target` subclass and instantiates it.
    class Mother
      def target_classes
        Target::Tracking.subclasses
      end


      # Allow one class to pose under another's nickname
      def pose_as(nickname, nickname_to_pose_as)
        nickname            = nickname.to_s
        nickname_to_pose_as = nickname_to_pose_as.to_s

        posing_class = target_classes[nickname           ] || raise(TargetError, "posing class '#{nickname}' doesn't exist!")
        old_class    = target_classes[nickname_to_pose_as]

        target_classes[nickname_to_pose_as] = posing_class
      end


      # Given a nickname, look up the `Target` subclass and create a memoised `Target::Call`.
      def target_class(nickname)
        raise(MobError, "no target nicknamed '#{nickname}'\navailable targets:\n#{target_classes.keys.inspect}") unless target_classes.key?(nickname.to_s)

        # Map nickname -> class
        target_classes[nickname.to_s]
      end


      def target(nickname, *args, &blk)
        target_class( nickname ).new( *args, &blk )
      end


      def key_classes 
        @key_classes ||= Hash.new {|h,k| h[k] = []}
      end
    end
  end
end
