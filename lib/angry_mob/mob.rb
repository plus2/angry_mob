class AngryMob
  class MobError < StandardError; end
  class Mob
    include Log

    attr_reader :node, :scheduler, :act_scheduler, :target_registry

    def initialize
      @target_registry = Target::Registry.new(self)
    end

    def riot!(nodename, attributes)
      start = Time.now
      log
      log "An AngryMob is rioting on #{nodename}."
      log

      @node          = Node.new(nodename, attributes)
      @scheduler     = TargetScheduler.new(self)
      @act_scheduler = ActScheduler.new(node)

      compile!
      run!

      log
      log "beaten in #{Time.now-start}s"
      log
      log "#{nodename} has been beaten by an AngryMob. Have a nice day!"

      @target_registry.clear_instances!
    end

    # bind selected targets to the node
    def compile!
      log "setting up node"
      defaults = AngryHash.new

      setup_node[node,defaults]       if setup_node
      node_defaults[node,defaults]    if node_defaults
      consolidate_node[node,defaults] if consolidate_node

      log "compiling"
      act_scheduler.each_act do |act_name|
        compile_act(act_name)
      end

      log "compilation complete"
      
      self
    end

    def compiled_acts
      @compiled_acts ||= {}
    end

    def compile_act(act_name)
      act_name = act_name.to_sym

      if compiled_acts[act_name]
        log "   (already compiled #{act_name})"
        return
      end

      compiled_acts[act_name] = true

      log " - #{act_name}"

      act = acts[act_name] || raise(MobError, "act '#{act_name}' doesn't exist")

      act.compile!
    end

    # runs targets bound to the node by compile!
    def run!
      scheduler.run!
    end


    # building
    # builder populates the following with definition blocks

    # node defaults
    attr_accessor :setup_node, :consolidate_node, :node_defaults

    # acts
    def acts
      @acts ||= Dictionary.new
    end
    
  end
end
