class AngryMob
  class Target
    class Call
      attr_reader :args, :klass, :actions
      attr_accessor :target

      def initialize(klass,args)
        @klass = klass
        @args  = Arguments.parse(args)
        validate_actions!
      end

      def self.instance_key(klass,args)
        klass.instance_key(Arguments.parse(args))
      end

      def instance_key
        self.class.instance_key(klass,args)
      end

      def add_args(new_args)
        @args = Arguments.parse(new_args).update_preserving_actions(args)
        validate_actions!
      end

      def merge_defaults(defaults)
        args.reverse_deep_merge!(defaults)
      end

      def call(act, hints={})
        target.act = act
        target.noticing_changes(args) {
          actions.each {|action|
            target.send(action)
          }
        }
      end

      def nickname
        klass.nickname
      end

      def validate_actions!
        @actions = args.actions

        extras = actions - klass.all_actions
        raise(ArgumentError, "#{nickname}() unknown actions #{extras.inspect} known=#{klass.all_actions.inspect}") unless extras.empty? || extras == ['nothing']

        actions << klass.default_action_name if actions.empty?

        if actions.norm.empty?
          raise ArgumentError, "#{klass.nickname}() no actions selected, and no default action defined"
        end
      end
    end
  end
end
