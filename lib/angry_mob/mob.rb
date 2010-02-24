class AngryMob
  class Mob
    def initialize
      add_builtin_targets
    end

    def riot!(nodename, attributes)
      node = Node.new(nodename, attributes)

      compile!(node)
      run!(node)
    end

    # bind selected targets to the node
    def compile!(node)

      setup_node[node] if setup_node

      # TODO - default act
      while act_name = node.next_act
        acts[act_name].compile!(node)
      end
      
      self
    end

    # runs targets bound to the node by compile!
    def run!(node)
      node.targets.each {|t| t.call(node)}
      node.delayed_targets.each {|t| t.call(node)}
    end

    # node defaults
    attr_accessor :setup_node

    # acts
    def acts
      @acts ||= Dictionary.new
    end


    # target classes
    def target_classes
      # TODO - guard against adding 2x
      @target_classes ||= Dictionary.new
    end

    def singleton_target_instances
      @singleton_target_instances ||= {}
    end

    def generators
      @generators ||= {}
    end

    def add_builtin_targets
      generators[:schedule_act] = lambda {|*args|
        lambda {|node| node.schedule_act *args }
      }
    end
    

    def target(nickname, *args, &block)
      if g = generators[nickname]
        return g[ [ args, block ].flatten.compact ]
      end

      raise(TargetError, "no target nicknamed #{nickname} found") unless target_classes.key?(nickname)
      klass = target_classes[nickname]

      if klass.ancestors.include?(AngryMob::SingletonTarget)
        singleton_target_instances[nickname] ||= klass.new(*args,&block)
        # XXX - update_args ?
      else
        klass.new(*args,&block)
      end
    end
    
  end
end
