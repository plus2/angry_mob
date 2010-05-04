require 'pathname'
require 'tsort'

class AngryMob
  class Builder
    autoload :Act    , "angry_mob/builder/act"
    
    include Log

    def self.from_file(path)
      path = Pathname(path)
      new.from_file(path)
    end

    attr_reader :node_consolidation_block

    def file
      if @file
        @file
      else
        '<no-file>'
      end
    end

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

      acts.each do |name,(blk,file)|
        Act.new(name,&blk).bind(mob,file)
      end

      mob
    end

    #### DSL API

    # Defines an `act` block
    def act(name, definition_file=nil, &blk)
      definition_file ||= file
      acts[name.to_sym] = [blk,definition_file.dup]
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

  end
end
