class AngryMob
  class Target
    # An `InternalApi` for `AngryMob::Target` subclasses to exploit.
    module InternalApi

      # Targets should override this (possibly calling super) to do their own validation.
      def validate!
        problem!("The default object wasn't set") if default_object.blank?
      end


      # Flag a validation problem.
      def problem!(problem)
        @problems ||= []
        @problems << problem
      end


      # Calculate and cache the state before any actions have been performed.
      def before_state
        @before_state ||= state
      end


      # Give the target itself a neat place to react to changes.
      # Default implementation is a no-op.
      def changed
        ui.log "target changed"
        # no-op
      end


      # Returns the state of the target.
      # Default implementation is a random number (i.e. it always changes)
      def state
        {
          :rand => rand
        }
      end


      # returns the default object
      # targets can customise this
      # the default is the default_object argument. 
      # See #initialize for how the default_option argument is set.
      def default_object(clear=false)
        @default_object = nil if clear
        @default_object ||= default_object!
      end
        
      
      # delegates to the node's resource locator
      def resource(name)
        node.resource_locator[self,name]
      end


      # delegates to the logger
      def log(message="")
        ui.log(message)
      end
        
    end
  end
end
