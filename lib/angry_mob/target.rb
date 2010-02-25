class AngryMob
  class TargetError < StandardError; end

  class TargetCall # TODO  < Blankslate
    attr_accessor :act
    attr_reader :action_names

    def initialize(target, action_names)
      @target = target
      @action_names = action_names
    end

    def call(node)
      @target.call(node,self)
    end

    def defined_at
      @defined_at ||= []
    end
    
    def add_caller(c)
      defined_at << c
    end

    def merge_defaults(defaults)
      @target.merge_defaults(defaults)
    end

    def inspect
      "#<TC:#{@target.nickname} obj=#{@target.default_object} actions=#{@action_names.inspect}>"
    end

    def method_missing(method,*args,&blk)
      @target.send method, *args, &blk
      self
    end
  end


  class Target
    include Log

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

    def initialize(*new_args)
      @args = Hashie::Mash.new(new_args.extract_options!)

      unless new_args.empty?
        @args.default_object = (new_args.size > 1 ? new_args : new_args.first)
      end
    end

    def build_call(*args)
      action_names = args.extract_options!.values_at(:action,:actions,'action','actions').compact

      action_names.delete_if {|a| a.blank?}

      action_names << self.class.default_action if action_names.blank?

      action_names.delete_if {|a| a.blank?}

      TargetCall.new(self, action_names)
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

    def log_divider(*msg)
      log "#{nickname}(#{default_object}) #{msg * ' '} #{'-' * 20}"
    end


    def before_state
      @before_state ||= state
    end

    def noticing_changes(node, ctx, &blk)

      log
      log_divider 'start'

      @node = node
      @ctx  = ctx

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
      @args.replace( Hashie::Mash.new(attrs).update(@args) ) # reverse merge
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
