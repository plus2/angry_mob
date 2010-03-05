class AngryMob
  class TargetError < StandardError; end
  class Target
    include Log

    autoload :Call    , 'angry_mob/target/call'
    autoload :Defaults, "angry_mob/target/defaults"
    autoload :Notify  , "angry_mob/target/notify"
    autoload :Flow    , "angry_mob/target/flow"

    class << self
      # TODO = build NotImplemented raising stubs
      def known_actions *actions
        @known_actions = actions.flatten
      end

      def default_action(name=nil, &blk)
        if name && blk
          action name, &blk
          @default_action = name
        else
          @default_action
        end
      end

      def actions
        @actions ||= Dictionary.new
      end

      def action(name, &blk)
        raise(TargetError, "action already exists for #{self}") if actions.key?(name)
        actions[name] = true
        define_method(name, &blk)
      end


      # building calls to this target

      # does this action has comprise only actions?
      def actions_only?(args)
        (args.keys - [:action,:actions,'action','actions']).empty?
      end

      def extract_args(*new_args)
        args = AngryHash[new_args.extract_options!]

        if default_object = extract_default_object(new_args,args)
          args.default_object = default_object
        end

        args
      end

      # extension point: extracts the default_object from the args
      def extract_default_object(arg_list, arg_hash)
        unless arg_list.empty?
          (arg_list.size > 1 ? arg_list : arg_list.first)
        end
      end

      # extension point: makes a unique key for this instance
      def instance_key(args)
        "#{nickname}:#{args.default_object.to_s}"
      end

      # build a call proxy for the named target
      #
      # interpret arguments
      # builds or retrieves an object instance
      # checks arguments - raises if semantics are violated
      # yields new target
      # builds a TargetCall
      def build_call(mob, *new_args, &blk)
        args = extract_args(*new_args)

        instance_key = instance_key(args)
        target       = yield(instance_key, nil) # fetch an existing instance

        if target && !actions_only?(args)
          raise TargetError, "you can't re-configure a target nickname=#{nickname} args=#{args.inspect[0..100]}"
        end

        if target.nil?
          target = new(args,&blk)
          yield instance_key, target # set a new instance
        end

        target.mob = mob

        target.build_call(args)
      end


      def nickname
        @nickname
      end

      def to_s
        "Target[#{nickname}]"
      end
    end # class << self


    def nickname
      self.class.nickname
    end

    attr_reader :ctx, :args
    attr_accessor :mob

    def initialize(args)
      @args = args
    end



    # call generation

    def normalise_actions(actions)
      actions = [ actions ].flatten.compact.map {|a| a.to_sym}.uniq.reject {|a| a.blank?}

      if actions.empty? && self.class.default_action
        actions << self.class.default_action.to_s
      end

      if actions.include? :nothing
        [:nothing]
      else
        actions
      end
    end

    def build_call(args)
      action_names = normalise_actions(args.delete_all_of(:action,:actions))
      Target::Call.new(self, action_names)
    end

    def call(mob,ctx=nil)
      if ctx
        action_names = [ ctx.action_names ]
      else
        action_names = []
      end

      action_names = normalise_actions(action_names)

      if action_names.include?(:nothing)
        log "not running (no actions requested)"
        return
      end

      action_names.each do |action|
        raise(TargetError, "No '#{action}' action found") unless respond_to?(action)
      end

      noticing_changes(mob,ctx) { action_names.each {|action| send(action)} }
    end

    def call_target(nickname, *args)
      call = mob.target(nickname,*args)
      call.act = ctx.act
      call.call(mob)
    end


    # runtime

    # runtime validation
    def do_validation!
      validate!
      unless @problems.blank?
        @problems.each {|p| log "problem: #{p}"}
        raise "target[#{nickname}] wasn't valid"
      end
    end

    # default validation
    def validate!
      problem!("The default object wasn't set") if default_object.blank?
    end

    def problem!(problem)
      @problems ||= []
      @problems << problem
    end

    def before_state
      @before_state ||= state
    end


    # executes actions with all the trimmings
    def noticing_changes(mob, ctx, &blk)
      log
      log "+#{'-' * 20}"
      log "  #{nickname}(#{default_object})"
      log

      @mob = mob
      @ctx = ctx

      do_validation!

      before_call if respond_to?(:before_call)


      for label,guard in guards
        unless guard.call
          log "stopped by guard: #{label}"
          log_end
          return
        end
      end

      before_state
      debug "before_state=#{before_state.inspect}"

      if node.dry_run?
        log "DRY RUN: skipping action"
      else
        yield
      end

      debug "after_state=#{state.inspect}"

      if changed?
        changed 
        notify
      else
        log "target didn't change"
      end

      log_end
      
    ensure
      @mob = nil
      @ctx  = nil
    end

    def log_end
      log
      log "  #{nickname}(#{default_object})"
      log "#{'-' * 21}"
      log
    end

    def node
      @mob.node
    end

    def mk_notify
      Notify.new(mob)
    end

    # delegates notification to the target scheduler
    def notify
      mob.scheduler.notify( args.notify ) if args.notify
    end

    # called when state changes after actions are called
    # default implementation is a no-op
    def changed
      log "target changed"
      # no-op
    end

    # has the state changed?
    def changed?
      before_state != state
    end

    # returns the state of the target
    # default implementation is a random number (i.e. it always changes)
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
      case args.default_object
      when Proc
        args.default_object[]
      else
        args.default_object
      end
    end

    # delegates to the resource locator
    def resource(name)
      node.resource_locator[self,name]
    end

    def merge_defaults(attrs)
      @args.reverse_deep_merge!(attrs)
    end

    def guards
      @guards ||= []
    end

    # adds an if? guard
    def if?(label='if?{}',&block)
      guards << [label,block]
      self
    end

    # adds an unless? guard
    def unless?(label='unless?{}',&block)
      guards << [label, lambda { not yield }]
      self
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
