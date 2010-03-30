class AngryMob
  class Target
    class Registry
      attr_reader :mob

      def initialize(mob)
        @mob = mob
      end

      # target classes
      def target_classes
        # TODO - guard against adding 2x
        @target_classes ||= AngryHash.new
      end

      def []=(nickname,target_class)
        target_classes[nickname.to_s] = target_class
      end
      def [](nickname)
        target_classes[nickname.to_s]
      end

      def pose_as(nickname,nickname_to_pose_as)
        nickname = nickname.to_s
        nickname_to_pose_as = nickname_to_pose_as.to_s

        posing_class = target_classes.tapp[nickname] || raise(TargetError, "posing class '#{nickname}' doesn't exist!")
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
      def key_classes 
        @key_classes ||= Hash.new {|h,k| h[k] = []}
      end

      def target(nickname, *args, &block)

        raise(MobError, "no target nicknamed '#{nickname}' found\n#{target_classes.keys.inspect}") unless target_classes.key?(nickname)
        klass = target_classes[nickname]

        args.options[:default_block] = block if block_given?

        klass.build_call(mob,*args) {|key,instance|
          key = key.to_s
          if instance.nil?
            target_instances[key]
          else
            key_classes[klass] << key
            target_instances[key] = instance
          end
        }
      end
    end
  end
end

