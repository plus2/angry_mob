class AngryMob
  class MobError < StandardError; end
  class Mob
    include Log

    attr_reader :node, :scheduler, :act_scheduler, :target_registry

    def initialize
      @target_registry = Target::Registry.new(self)
      @act_scheduler = ActScheduler.new
    end

    def riot!(nodename, attributes)
      start = Time.now
      log
      log "An AngryMob is rioting on #{nodename}."
      log

      @node               = Node.new(nodename, attributes)
      @act_scheduler.node = @node
      @scheduler          = TargetScheduler.new(self)

      setup!
      run!

      log
      log "beaten in #{Time.now-start}s"
      log
      log "#{nodename} has been beaten by an AngryMob. Have a nice day!"

      @target_registry.clear_instances!
      @act_scheduler.reset!
    end

    # bind selected targets to the node
    def setup!
      log "setting up node"
      defaults = AngryHash.new

      setup_node[node,defaults]       if setup_node
      node_defaults[node,defaults]    if node_defaults
      consolidate_node[node,defaults] if consolidate_node

      log "setup complete"
      
      self
    end

    # runs acts and then delayed targets
    def run!
      act_scheduler.run!
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
