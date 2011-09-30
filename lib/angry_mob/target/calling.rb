class AngryMob
  class Target
    module Calling

      # Merge current defaults into the arguments
      def merge_defaults(defaults)
        args.reverse_deep_merge!(defaults)
      end


      # Actually call the target
      def call_with_act(act, hints={})
        self.act = act
        noticing_changes do
          args.actions.each {|action| __send__(action)}
        end
      end


      # Ensure that we have a known action.
      def validate_actions!
        all_actions = self.class.all_actions

        # Ensure that the action is known (or is 'nothing')
        extras = args.actions - all_actions

        raise(ArgumentError, "#{nickname}() unknown actions #{extras.inspect} known=#{all_actions.inspect}") unless extras.empty? || extras == ['nothing']

        # Add the default action if no other actions were specified.
        args.actions << self.class.default_action_name if args.actions.empty?

        # Ensure that there's at least one action.
        if args.actions.norm.empty?
          raise ArgumentError, "#{nickname}() no actions selected, and no default action defined"
        end
      end
    end
  end
end
