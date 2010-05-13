class AngryMob
  class Target
    class Mother
      attr_reader :mob

      def initialize(mob)
        @mob = mob
      end

      def target_classes
        Target::Tracking.subclasses
      end

      def pose_as(nickname,nickname_to_pose_as)
        raise "not impl"
        nickname = nickname.to_s
        nickname_to_pose_as = nickname_to_pose_as.to_s

        posing_class = target_classes[nickname] || raise(TargetError, "posing class '#{nickname}' doesn't exist!")
        old_class = target_classes[nickname_to_pose_as]

        target_classes[nickname_to_pose_as] = posing_class

        if old_class && instances = key_classes.delete(old_class)
          # TODO - merge instances if required
        end
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

      def target_call(nickname, *args)
        raise(MobError, "no target nicknamed '#{nickname}'\n#{target_classes.keys.inspect}") unless target_classes.key?(nickname.to_s)
        klass = target_classes[nickname.to_s]

        args = Arguments.parse(args)

        if key = Target::Call.instance_key(klass,args)
          if call = target_instances[key]
            call.add_args(args)
          else
            call = target_instances[key] = Target::Call.new( klass, args )
          end
        else
          unkeyed_instances << call = Target::Call.new( klass, args )
        end

        call.target ||= klass.new

        call
      end
    end
  end
end
