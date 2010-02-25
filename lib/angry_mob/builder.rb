require 'pathname'
class AngryMob
  class TargetCreationContext
    def initialize(&blk)
      @blk = blk
    end

    def bind(mob)
      @mob = mob
      instance_eval(&@blk)
      self
    end

    def SingletonTarget(nickname,&blk)
      @mob.target_classes[nickname] = Class.new(SingletonTarget, &blk)
    end

    def Target(nickname,&blk)
      @mob.target_classes[nickname] = Class.new(Target, &blk)
    end
    
    def method_missing(method,*args,&blk)
      if args.size == 1
        @mob.target_classes[args.first] = Class.new(@mob.target_classes[method], &blk)
      else
        super
      end
    end
  end

  class BuilderDefaults
    def initialize
      @contexts = Hash.new {|h,k| h[k] = []}
    end

    def defaults_for(name)
      @contexts[name].last || {}
      # TODO -> merge under some circumstances
    end

    def method_missing(method, *args, &blk)
      @contexts[method] << args.first

      if block_given?
        yield
        @contexts[method].pop
      end
    end
  end

  class NotifyBuilder
    def initialize(mob,node)
      @mob,@node = mob,node

      @target = nil
      @target_args = nil

      @when   = :later
      @actions = []
    end

    def method_missing(method,*args,&blk)
      if ! @target
        @target = method
        @target_args = args

      elsif method == :later || method == :now
        @when = method

      else
        @actions << method

      end

      return self
    end
  end

  class ActBuilder
    def initialize(name,&blk)
      @name = name
      @blk = blk
    end

    def bind(mob)
      @mob = mob
      mob.acts[@name] = self
    end

    def compile!(node)
      @node = node
      @act = Act.new(@name)
      instance_exec node, &@blk
    end

    def defaults
      @defaults ||= BuilderDefaults.new
    end

    def method_missing(method,*args,&blk)
      @node.targets << t = @mob.target(method,*args,&blk)

      t.merge_defaults(defaults.defaults_for(method)) if t.respond_to?(:merge_defaults)

      t
    end
  end


  class Builder
    def self.from_file(path)
      path = Pathname(path)
      new.from_file(path)
    end

    def from_file(path)
      instance_eval path.read, path.to_s
      self
    end

    def initialize
    end

    def node_setup_blocks
      @node_setup_blocks ||= []
    end

    def setup_node(&blk)
      node_setup_blocks << blk
    end

    def acts
      @acts ||= Dictionary.new
    end

    def target_blocks
      @target_blocks ||= []
    end

    def act(name, &blk)
      acts[name] = blk
    end

    def targets(&blk)
      target_blocks << blk
    end

    def to_mob
      mob = Mob.new

      mob.setup_node = lambda {|node|
        node_setup_blocks.each {|blk| blk[node]}
      }

      target_blocks.each do |blk|
        TargetCreationContext.new(&blk).bind(mob)
      end

      acts.each do |name,blk|
        ActCreationContext.new(name,&blk).bind(mob)
      end

      mob
    end
  end
end
