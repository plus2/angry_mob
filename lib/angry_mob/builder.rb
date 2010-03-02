require 'pathname'
require 'tsort'

class AngryMob
  class TargetList < Hash
    include TSort

    alias_method :tsort_each_node, :each_key
    def tsort_each_child(node, &block)
      fetch(node)[:dependencies].each(&block)
    end

    def add_block(name,blk,dependencies)
      dependencies = [ dependencies ].flatten.compact.map {|k| k.to_s}
      self[name.to_s] = {:block => blk, :dependencies => dependencies}
    end

    def each_target(&block)
      each_strongly_connected_component do |name|
        name = name.first
        yield name, fetch(name)[:block]
      end
    end
  end

  class Builder
    autoload :Targets, "angry_mob/builder/targets"
    autoload :Act    , "angry_mob/builder/act"

    def self.from_file(path)
      path = Pathname(path)
      new.from_file(path)
    end

    # read and evaluate a file in builder context
    def from_file(path)
      instance_eval path.read, path.to_s
      self
    end

    def act(name, &blk)
      acts[name.to_sym] = blk
    end

    def targets(name,opts={},&blk)
      target_blocks.add_block(name,blk,opts[:requires])
    end

    def to_mob
      mob = Mob.new

      mob.setup_node = lambda {|node|
        node_setup_blocks.each {|blk| blk[node]}
      }

      target_blocks.each_target do |name,blk|
        Targets.new(name,&blk).bind(mob)
      end

      acts.each do |name,blk|
        Act.new(name,&blk).bind(mob)
      end

      mob
    end

    protected
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
      @target_blocks ||= TargetList.new
    end

  end
end
