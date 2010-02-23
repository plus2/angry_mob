class AngryMob
  class Act
    def initialize(name)
      @name = name
    end

    def blocks
      @blocks ||= [] 
    end

    def add_block(&block)
      blocks << block
    end

    def <<(target)
      @node.targets << target
    end

    def compile!(node)
      @node = node

      blocks.each do |b|
        instance_exec(self,node,&b)
      end
    ensure
      @node = nil
    end

    def schedule_act act_name
      # XXX how will this work?
    end

    def method_missing(method, *args, &block)
      @node.targets << t = Target.new_target(method, *args, &block)
      t
    end
  end
end
