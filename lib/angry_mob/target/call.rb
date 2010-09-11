class AngryMob
  class Target
    ## Call
    # Wraps a Target class and instance in call semantics and argument handling.
    class Call
      attr_reader :args, :klass, :actions
      attr_accessor :target

      def initialize(klass,args)
        @klass = klass
        @args  = Arguments.parse(args)
        validate_actions!
      end

      # Delegate to the Target subclass to create a unique `instance_key`
      def self.instance_key(klass,args)
        klass.instance_key(Arguments.parse(args))
      end

      def instance_key
        self.class.instance_key(klass,args)
      end

      # Replace arguments, but preserve the original actions.
      def add_args(new_args)
        @args = Arguments.parse(new_args).update_preserving_actions(args)
        validate_actions!
      end

      # Merge current defaults into the arguments
      def merge_defaults(defaults)
        args.reverse_deep_merge!(defaults)
      end

      # Actually call the target
      def call(act, hints={})
        target.act = act
        target.noticing_changes(args) {
          actions.each {|action|
            target.send(action)
          }
        }
      end

      # The `Target`'s nickname
      def nickname
        klass.nickname
      end

      # Ensure that we have a known action.
      def validate_actions!
        @actions = args.actions

        # Ensure that the action is known (or is 'nothing')
        extras = actions - klass.all_actions
        raise(ArgumentError, "#{nickname}() unknown actions #{extras.inspect} known=#{klass.all_actions.inspect}") unless extras.empty? || extras == ['nothing']

        # Add the default action if no other actions were specified.
        actions << klass.default_action_name if actions.empty?

        # Ensure that there's at least one action.
        if actions.norm.empty?
          raise ArgumentError, "#{klass.nickname}() no actions selected, and no default action defined"
        end
      end
    end
  end
end
