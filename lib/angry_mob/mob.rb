class AngryMob
  class MobError < StandardError; end
  class Mob
    include Log

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
      log "setting up node"
      setup_node[node] if setup_node

      # TODO - default act

      log "compiling"

      while act_name = node.next_act
        compile_act(node,act_name)
      end

      log "compilation complete"
      
      self
    end

    def compile_act(node,act_name)
      log " - #{act_name}"

      act_name = act_name.to_sym

      act = acts[act_name] || raise(MobError, "act '#{act_name}' doesn't exist")

      act.compile!(node)
    end

    # runs targets bound to the node by compile!
    def run!(node)
      node.run!
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
      #generators[:schedule_act] = lambda {|*args|
      #  lambda {|node| node.schedule_act *args }
      #}
      #   generators[:act_now] = lambda {|*args|
      #     lambda {|node| node.act_now *args }
      #   }
    end
    

    def target(nickname, *args, &block)
      if g = generators[nickname]
        return g[ [ args, block ].flatten.compact ]
      end

      raise(TargetError, "no target nicknamed '#{nickname}' found") unless target_classes.key?(nickname)
      klass = target_classes[nickname]

      # XXX - all targets should be "singletons", so that notifications can refer to them
      #
      target = if klass.ancestors.include?(AngryMob::SingletonTarget)
        singleton_target_instances[nickname] ||= klass.new(*args,&block)
        # XXX - update_args ?
      else
        klass.new(*args,&block)
      end

      target.build_call(*args)
    end
    
  end
end
