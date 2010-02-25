class AngryMob
  class TargetError < StandardError; end
  class Target
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
    end # class << self


    def initialize(*args)
      @args = if Hash === args.last then args.pop else {} end
      unless args.empty?
        @args[:default] = (args.size > 1 ? args : args.first)
      end
    end

    def call(node)
      raise(TargetError, "No default action found") unless self.class.default_action

      noticing_changes(node) { send( self.class.default_action ) }
    end

    def [](*run_actions)
      run_actions.each do |action|
        raise(TargetError, "No '#{action}' action not found") unless self.class.actions.key?(action)
      end

      lambda {|node|
        noticing_changes(node) { run_actions.each {|action| send(action)} }
      }
    end

    attr_reader :node

    def noticing_changes(node, &blk)
      before = state
      @node = node

      yield

      if changed?(before)
        changed 
        notify
      end
    ensure
      @node = nil
    end

    def notify
      node.notify( @args[:notify] ) if @args[:notify]
    end

    def changed
      # no-op
    end

    def changed?(pre_state)
      pre_state != state
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
