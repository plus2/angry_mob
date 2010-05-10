require "angry_mob/target/tracking"

class AngryMob
  class TargetError < StandardError; end
  class Target
    autoload :Mother  , 'angry_mob/target/mother'
    autoload :Call    , 'angry_mob/target/call'
    autoload :Defaults, "angry_mob/target/defaults"
    autoload :Notify  , "angry_mob/target/notify"
    autoload :Arguments, "angry_mob/target/arguments"

    include Tracking

    # Ok lets define some class level helpings.
    class << self
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


      # Based on the args, makes a unique key for a target instance.
      # This could be overridden by subclasses.
      def instance_key(args)
        args.key
      end

      protected
      def create_action(method)
        return if self == AngryMob::Target # XXX protect methods properly and remove this
        # puts "creating action #{method} for #{self}"

        if @set_default_action && @default_action
          raise ArgumentError, "#{nickname}() can only have one default_action"
        end

        @default_action = method.to_s if @set_default_action
        actions << method.to_s

        @set_default_action = nil
      end

      def baseclass #:nodoc:
        AngryMob::Target
      end

    end # class << self

    def nickname
      self.class.nickname
    end

    attr_reader :args, :current_action
    attr_accessor :act

    def mob; act.mob end
    def ui ; mob.ui  end

    def log(message); mob.ui.log message end

    #### Call generation

    # nothing actions are no-ops but by being called, prevent the default action being called
    def nothing(*)
      false
    end


    #### Definition-time helpers
    def to_s
      if default_object
        "#{nickname}(#{default_object})"
      else
        "#{nickname}()"
      end
    end


    # Executes actions with full context and all the trimmings.
    def noticing_changes(args,&blk)
      reset!
      @args = args

      ui.push(to_s) do
        do_validation!

        before_state
        before_call if respond_to?(:before_call)

        ui.debug "before_state=#{before_state.inspect}"

        if skip?
          ui.skipped! "skipping"
          return
        end

        # Here's the core of the target:
        if node.dry_run?
          ui.skipped! "DRY RUN: skipping action"
          return
        else
          # riiight here:
          yield
        end

        ui.debug "after_state=#{state.inspect}"

        # If the state's changed, let it be known
        if state_changed?
          changed 
          notify
          ui.ok!
        else
          ui.skipped! "target didn't change"
        end
      
      end
      self
    end

    # Has the state changed?
    #   dir("/tmp/config").changed? && sh("echo it changed")
    def changed?
      state_changed?
    end


    protected

    def reset!
      @skip = nil
      @args = nil
    end

    def skip!
      @skip = true
    end

    def skip?
      !! @skip
    end

    #### Runtime

    # Do some very basic runtime validation. This validation is bound very late!
    def do_validation!
      validate!
      unless @problems.blank?
        @problems.each {|p| ui.error "problem: #{p}"}
        raise "target[#{nickname}] wasn't valid"
      end
    end

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



    def node
      mob.node
    end

    def mk_notify
      Notify.new(act)
    end

    # Very simply delegates notification to the target scheduler
    def notify
      mob.target_scheduler.notify( args.notify ) if args.notify
    end

    # Give the target itself a neat place to react to changes.
    # Default implementation is a no-op.
    def changed
      ui.log "target changed"
      # no-op
    end

    # has the state changed?
    def state_changed?
      before_state != state
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
    def default_object
      @default_object ||= default_object!
    end

    def default_object!
      return unless args

      case args.default_object
      when Proc
        args.default_object[]
      else
        args.default_object
      end
    end

    # delegates to the node's resource locator
    def resource(name)
      node.resource_locator[self,name]
    end

    def log(message="")
      ui.log(message)
    end

    # delegate to the default object
    def method_missing(method,*args,&blk)
      if (dobj = default_object) && dobj.respond_to?(method)
        dobj.send(method,*args,&blk)
      else
        super
      end
    end
  end
end
