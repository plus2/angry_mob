# TODO - remove, its role has been usurped
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

    def method_missing(method, *args, &block)
      Target.new_target(method, *args, &block)
    end
  end
end
