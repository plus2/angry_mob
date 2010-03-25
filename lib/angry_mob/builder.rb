require 'pathname'
require 'tsort'

class AngryMob
  # `TargetList` is a hash for topologically sorting target blocks. Thus it provides simple dependency handling.
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
    
    include Log

    def self.from_file(path)
      path = Pathname(path)
      new.from_file(path)
    end

    attr_reader :file, :node_consolidation_block

    # read and evaluate a file in builder context
    def from_file(path)
      @file = path
      instance_eval path.read, path.to_s
      @file = nil
      self
    end

    def to_mob
      mob = Mob.new

      # pre-setup
      mob.setup_node = lambda {|node,defaults|
        node_setup_blocks.each {|blk| blk[node,defaults]}
      }

      # in-setup
      mob.node_defaults = lambda {|node,defaults|
        node_default_blocks.each {|blk| blk[node,defaults]}
      }

      # post-setup
      mob.consolidate_node = @node_consolidation_block

      target_blocks.each_target do |name,blk|
        Targets.new(name,&blk).bind(mob)
      end

      acts.each do |name,(blk,file)|
        Act.new(name,&blk).bind(mob,file)
      end

      mob
    end

    #### DSL API

    # Defines an `act` block
    def act(name, &blk)
      acts[name.to_sym] = [blk,@file.dup]
    end

    # Defines a `targets` block
    def targets(name,opts={},&blk)
      target_blocks.add_block(name,blk,opts[:requires])
    end

    # A `setup_node` block allows the mob to set defaults, load resource locators and anything else you like.
    def setup_node(&blk)
      node_setup_blocks << blk
    end

    def consolidate_node(&blk)
      @node_consolidation_block = blk
    end

    # Defaults
    def node_defaults(&blk)
      node_default_blocks << blk
    end


    protected
    def node_setup_blocks
      @node_setup_blocks ||= []
    end
    def node_default_blocks
      @node_default_blocks ||= []
    end

    def acts
      @acts ||= Dictionary.new
    end

    def target_blocks
      @target_blocks ||= TargetList.new
    end

  end
end
