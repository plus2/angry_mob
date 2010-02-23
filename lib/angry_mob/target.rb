class AngryMob
  class TargetError < StandardError; end
  class Target
    class << self
      def known_actions *actions
        @known_actions = actions.flatten
        # TODO = build NotImplemented raising stubs
      end

      def default_action(name, &blk)
        action name, &blk
        @default_action = name
      end

      def actions
        @actions ||= Dictionary.new
      end

      def action(name, &blk)
        raise(TargetError, "action already exists for #{self}") if actions.key?(name)
        actions[name] = blk
      end

      def state(&blk)
        @state = blk
      end

      def targets
        @@targets ||= Dictionary.new
      end

      def instances
        @@instances ||= {}
      end

      def new_target(nickname, *args, &block)
        raise(TargetError, "no target nicknamed #{nickname} found") unless targets.key?(nickname)
        klass = targets[nickname]

        if klass.ancestors.include?(AngryMob::SingletonTarget)
          instances[nickname] ||= klass.new(*args,&block)
          # XXX - update_args ?
        else
          klass.new(*args,&block)
        end
      end

      def nickname(name)
        raise "target with nickname #{name} already defined" if targets.key?(name)
        targets[name] = self

        @nickname = name
      end
    end

    def initialize(*args)
      @args = if Hash === args.last then args.pop else {} end
      unless args.empty?
        @args[:default] = (args.size > 1 ? args : args.first)
      end
    end

    def call
      # XXX - uses default action, raises if there isn't one!
      find_default || raise
      before = state
      default[]
      changed if changed?(before)
    end

    def [](*actions)
      # XXX - returns lambda composing calls to each named action
    end

    def notify
      # XXX - is called when pre state != post state
    end

    # TODO - do stuff when updated or changed ?
    def changed
    end
    def updated 
    end

    def default_object
      @args[:default]
    end
    def method_missing(method,*args,&blk)
      # XXX - delegates to default object
    end
  end
end
