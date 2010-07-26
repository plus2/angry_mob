require 'pathname'
require 'tsort'

class AngryMob
  class Builder
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

      # create and bind acts
      acts.each do |name,(blk,file,multi)|
        act = Act.new(name,multi,&blk)
        act.extend helper_mod 
        act.bind(mob,file)
      end

      mob
    end

    #### DSL API

    # Defines an `act` block
    def act(name, definition_file=nil, &blk)
      definition_file ||= file
      acts[name.to_sym] = [blk,definition_file.dup,false]
    end

    def multi_act(name, definition_file=nil, &blk)
      definition_file ||= file
      acts[name.to_sym] = [blk,definition_file.dup,true]
    end

    def act_helper(&blk)
      helper_mod.module_eval(&blk)
    end

    def finalise(*act_names, &blk)
      act_names.norm.each {|a| act("finalise/#{a}",&blk)}
    end

    def notifications_for(name,&blk)
      act("notifications_for/#{name}") { notifications.for(name, :context => self, &blk) }
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

    def helper_mod
      @helper_mod ||= Module.new
    end

  end
end
