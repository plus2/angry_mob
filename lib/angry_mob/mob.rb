class AngryMob
  class MobError < StandardError; end
  class Mob
    include Log

    def initialize
      @compiled_acts = {}
      add_builtin_targets
    end

    def riot!(nodename, attributes)
      start = Time.now
      log
      log "An AngryMob is rioting on #{nodename}."
      log

      node = Node.new(nodename, attributes)
      compile!(node)
      run!(node)

      log
      log "beaten in #{Time.now-start}s"
      log
      log "#{nodename} has been beaten by an AngryMob. Have a nice day!"
    end

    # bind selected targets to the node
    def compile!(node)
      log "setting up node"
      setup_node[node] if setup_node

      log "compiling"
      while act_name = node.next_act
        compile_act(node,act_name)
      end

      log "compilation complete"
      
      self
    end

    def compile_act(node,act_name)
      act_name = act_name.to_sym

      if @compiled_acts[act_name]
        log "   (already compiled #{act_name})"
        return
      end

      @compiled_acts[act_name] = true

      log " - #{act_name}"

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

    def target_instances
      @target_instances ||= {}
    end

    def generators
      @generators ||= {}
    end

    def add_builtin_targets
    end

    def target(nickname, *args, &block)
      if g = generators[nickname]
        return g[ [ args, block ].flatten.compact ]
      end

      raise(MobError, "no target nicknamed '#{nickname}' found\n#{target_classes.keys.inspect}") unless target_classes.key?(nickname)
      klass = target_classes[nickname]

      klass.build_call(self,*args) {|key,instance|
        if instance.nil?
          target_instances[key]
        else
          target_instances[key] = instance
        end
      }
    end
    
  end
end
