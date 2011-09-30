class AngryMob
  class Target
    # class-level API for Target subclasses to exploit.
    module ClassApi
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def default_action
          @set_default_action = true
        end


        def actions
          @actions ||= ['nothing']
        end


        def all_actions
          @all_actions ||= from_superclass(:all_actions, ['nothing'])
          @all_actions |= actions
        end


        def default_action_name
          @default_action
        end
      end
    end
  end
end
