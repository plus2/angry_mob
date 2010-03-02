class AngryMob
  class TargetError < StandardError; end
  class Target
    include Log

    autoload :Call, 'angry_mob/target/call'

    class << self
      def known_actions *actions
        @known_actions = actions.flatten
        # TODO = build NotImplemented raising stubs
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

      def actions_only?(args)
        (args.keys - [:action,:actions,'action','actions']).empty?
      end

      def extract_args(*new_args)
        args = AngryHash[new_args.extract_options!]

        unless new_args.empty?
          args.default_object = (new_args.size > 1 ? new_args : new_args.first)
        end

        args
      end

      def instance_key(args)
        "#{nickname}:#{args.default_object}"
      end

      # interpret arguments
      # builds or retrieves an object instance
      # checks arguments and warns for semantic nuance
      # yields new target
      # builds a TargetCall
      def build_call(mob, *new_args, &blk)
        args = extract_args(*new_args)

        instance_key = instance_key(args)
        target       = yield(instance_key, nil)

        if target && !actions_only?(args)
          puts "Warning: you can't re-configure a target nickname=#{nickname} args=#{args.inspect[0..100]}"
          caller[1..5].tapp
        end

        if target.nil?
          target = new(args,&blk)
          yield instance_key, target
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

    attr_reader :node, :ctx, :args
    attr_accessor :mob

    def initialize(args)
      @args = args
    end

    def build_call(args)
      action_names = args.delete_all_of(:action,:actions).flatten.compact

      # TODO - handle :nothing action

      action_names.delete_if {|a| a.blank?}

      action_names << self.class.default_action if action_names.blank?

      action_names.delete_if {|a| a.blank?}

      Target::Call.new(self, action_names)
    end

    def call(node,ctx=nil)
      if ctx
        action_names = [ ctx.action_names ]
      else
        action_names = []
      end

      action_names.flatten!
      action_names.compact!

      action_names << self.class.default_action if action_names.blank?

      action_names.each do |action|
        raise(TargetError, "No '#{action}' action found") unless respond_to?(action)
      end

      noticing_changes(node,ctx) { action_names.each {|action| send(action)} }
    end

    def call_target(nickname, *args)
      call = mob.target(nickname,*args)
      call.act = ctx.act
      call.call(node)
    end

    def log_divider(*msg)
      log "#{nickname}(#{default_object}) #{msg * ' '} #{'-' * 20}"
    end

    def do_validation!
      validate!
      unless @problems.blank?
        @problems.each {|p| log "problem: #{p}"}
        raise "target[#{nickname}] wasn't valid"
      end
    end

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

    def noticing_changes(node, ctx, &blk)
      log
      log_divider 'start'

      @node = node
      @ctx  = ctx

      do_validation!

      before_call if respond_to?(:before_call)


      for label,guard in guards
        unless guard.call
          log "stopped by guard: #{label}"
          return
        end
      end

      before_state
      log "before_state=#{before_state.inspect}"

      yield

      if changed?
        changed 
        notify
      else
        log "target didn't change"
      end
    ensure
      log_divider 'end  '
      @node = nil
      @ctx  = nil
    end

    def mk_notify
      NotifyBuilder.new(mob,node)
    end

    def notify
      node.notify( args.notify ) if args.notify
    end

    def changed
      log "target changed"
      # no-op
    end

    def changed?
      before_state != state
    end

    def state
      {}
    end

    def default_object
      args.default_object
    end

    def merge_defaults(attrs)
      @args.reverse_deep_merge!(attrs)
    end

    def guards
      @guards ||= []
    end

    def if?(label='if?{}',&block)
      guards << [label,block]
    end

    def unless?(label='unless?{}',&block)
      guards << [label, lambda { not yield }]
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
