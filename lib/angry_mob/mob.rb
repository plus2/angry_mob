class AngryMob
  class Mob
    def acts
      @acts ||= Dictionary.new
    end

    def add_act(name, &block)
      act = acts[name] ||= Act.new(name)
      act.add_block(&block)
    end

    def riot!(nodename, attributes)
      node = Node.new(nodename, attributes)

      compile!(node)
      run!(node)
    end

    def run!(node)
      node.targets.tapp
      # XXX - node.targets.each {|t| t.call}
    end

    def compile!(node)
      remaining_acts = (node.attributes[:acts] || []).dup

      while act_name = remaining_acts.shift
        acts[act_name].compile!(node)
      end
    end
  end
end
