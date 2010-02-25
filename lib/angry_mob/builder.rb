require 'pathname'
class AngryMob
  class TargetBuilder
    def initialize(&blk)
      @blk = blk
    end

    def bind(mob)
      @mob = mob
      instance_eval(&@blk)
      self
    end

    def TargetHelpers(&blk)
      @helpers = Module.new(&blk).tapp
    end

    def add_class(nickname,superclass,&blk)
      klass = @mob.target_classes[nickname] = Class.new(superclass, &blk)
      if h = @helpers
        klass.module_eval {
          @nickname = nickname
          include h
        }
      end
    end

    def SingletonTarget(nickname,&blk)
      add_class(nickname,SingletonTarget,&blk)
    end

    def Target(nickname,&blk)
      add_class(nickname,Target,&blk)
    end
    
    def method_missing(method,*args,&blk)
      if args.size == 1
        add_class(args.first, @mob.target_classes[method], &blk)
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
      instance_exec node, &@blk
    end

    def defaults
      @defaults ||= BuilderDefaults.new
    end

    def notify
      NotifyBuilder.new(@mob,@node)
    end

    def node
      @node
    end

    def act_now *act_name
      act_name.flatten!
      act_name.compact!
      act_name.each {|act_name| @mob.compile_act(@node, act_name)}
    end

    def schedule_act act_name
      node.schedule_act(act_name)
    end

    if instance_methods.include? :gem
      undef :gem
    end

    def method_missing(method,*args,&blk)
      # TODO - record where it was defined
      @node.targets << t = @mob.target(method,*args,&blk)

      t.add_caller(caller(1).first) if t.respond_to?(:add_caller)
      t.act = @name

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
      acts[name.to_sym] = blk
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
        TargetBuilder.new(&blk).bind(mob)
      end

      acts.each do |name,blk|
        ActBuilder.new(name,&blk).bind(mob)
      end

      mob
    end
  end
end
