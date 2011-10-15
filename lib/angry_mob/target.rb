class AngryMob
  class TargetError < StandardError; end
  class Target
    autoload :Mother   , 'angry_mob/target/mother'
    autoload :Defaults , "angry_mob/target/defaults"
    autoload :Arguments, "angry_mob/target/arguments"

    autoload :DefaultResourceLocator, "angry_mob/target/default_resource_locator"


    require "angry_mob/target/tracking"
    require "angry_mob/target/class_api"
    require "angry_mob/target/internal_api"
    require "angry_mob/target/calling"


    include Tracking
    include ClassApi
    include InternalApi
    include Calling


    def nickname
      self.class.nickname
    end


    attr_reader :ui, :node, :definition_file, :args, :current_action


    def initialize(act, args, &blk)
      bind_act(act)
      @args = Arguments.parse(args, &blk)
      validate_actions!
    end


    def bind_act(act)
      @definition_file = act.definition_file
      @ui              = act.ui
      @node            = act.node
      @act_scheduler   = act.act_scheduler
    end


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
    def noticing_changes(&blk)
      reset!

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
          fire!
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

    # Called when the state has changed.
    # Very simply delegates event to the act scheduler
    def fire!
      act_scheduler.fire(args.fire) if args.fire.present?
    end
    

    def reset!
      @skip = nil
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
        ui.error "There were problems validating #{self}:"
        @problems.each {|p| ui.error "problem: #{p}"}
        raise "target[#{nickname}] wasn't valid"
      end
    end


    # has the state changed?
    def state_changed?
      before_state != state
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


    def action?(*actions)
      !( actions.norm.map {|a| a.to_s} & args.actions ).empty?
    end
  end
end
