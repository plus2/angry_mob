class AngryMob
  class MobError < StandardError; end
  class Rioter
    attr_reader :node, :act_scheduler

    def initialize
      @act_scheduler = Act::Scheduler.new
    end


    class << self
      # delegate to the current ui
      def ui
        (@ui ||= ui!).current
      end


      def ui!
        @ui = UI.new
      end


      def ui=(ui)
        @ui = ui
      end
    end


    def ui
      self.class.ui
    end


    # main entry point the the whole system
    def riot!(nodename, attributes)
      start = Time.now
      ui.info "An AngryMob is rioting on #{nodename}."

      @node               = Node.new(nodename, attributes)
      @act_scheduler.node = @node

      setup!
      run!

      ui.info "beaten in #{Time.now-start}s"
      ui.info "#{nodename} has been beaten by an AngryMob. Have a nice day!"

      @act_scheduler.reset!
    end


    # bind selected targets to the node
    def setup!
      ui.task "setting up node"
      defaults = AngryHash.new

      setup_node[node,defaults]       if setup_node
      node_defaults[node,defaults]    if node_defaults
      consolidate_node[node,defaults] if consolidate_node

      node.setup_finished!

      ui.good "setup complete"
      
      self
    end


    # runs acts and then delayed targets
    def run!
      act_scheduler.run!
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
