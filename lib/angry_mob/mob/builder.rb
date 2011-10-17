require 'pathname'
require 'tsort'

class AngryMob
	class Mob
		class Builder
			include Log

			attr_reader :attributes, :mob


			def initialize(mob, attributes)
				@mob        = mob
				@attributes = attributes
			end


			def ui; mob.ui end

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
				old_eval_path,@current_eval_path = @current_eval_path,path
				instance_eval path.read, path.to_s
			ensure
				@current_eval_path = old_eval_path
			end


			def from_block(mob, &blk)
				with_mob(mob, '<block>') do
					instance_eval(&blk)
				end
			end


			def with_mob(mob,path)
				@mob  = mob
				@file = path
				yield
				self
			ensure
				@mob  = nil
				@file = nil
			end


			# Assembles the rioter from Act definitions
			def add_to_rioter(rioter)

				# pre-setup - combine blocks added
				rioter.setup_node = lambda {|node,defaults|
					node_setup_blocks.each {|blk| blk[node,defaults]}
				}

				# in-setup - combine blocks added
				rioter.node_defaults = lambda {|node,defaults|
					node_default_blocks.each {|blk| blk[node,defaults]}
				}

				# post-setup
				rioter.consolidate_node = @node_consolidation_block

				# create and bind acts
				acts.each do |act|
					act.extend helper_mod 
					act.bind_rioter(rioter)
				end

				# bind event processors
				event_processors.each do |ev_proc|
					ev_proc.bind(rioter)
				end

				rioter = Rioter.new
				rioter
			end



			# building

			def build_mob!(build_block)
				if build_block
					instance_exec mob.path, &build_block
				else
					# default impl
				end
			end




			###############
			#  build api  #
			###############

			# Load all targets under `path`
			def add_targets_from(path)
				raise "targets path #{path} didn't exist" unless path.exist?
				ui.log "loading targets from #{path}"

				$LOAD_PATH << path
				Pathname.glob(path+'**/*.rb').each do |file|
					require file
				end
			end


			# Add `path` to the load path
			def add_lib(path)

				raise "lib path #{path} didn't exist" unless path.exist?

				ui.log "adding load path #{path}"
				$LOAD_PATH << path
			end


			# Load all acts under `path`
			def add_acts_from(path)
				raise "acts path #{path} didn't exist" unless path.exist?
				ui.log "loading acts from #{path}"

				# load each file... 'higher' files first
				depth_sorted_paths = Pathname.glob(path+'**/*.rb').sort_by {|file| file.to_s.split('/').size }
				
				depth_sorted_paths.each do |file|
					from_file(file)
				end
			end



			# Load acts from the file at `path`.
			def load_act_file(path)
				raise "act file at path #{path} didn't exist" unless path.exist?
				ui.log "loading acts from #{path}"

				from_file(path)
			end



			##################
			#  Act File API  #
			##################



			# Defines an `act` block
			def act(*args, &blk)
				acts << Act.new(mob, @current_eval_path, *args, &blk)
			end


			def event(*args,&blk)
				event_processors << AngryMob::Act::EventProcessor.new(*args,&blk)
			end


			def act_helper(&blk)
				helper_mod.module_eval(&blk)
			end


			# A `setup_node` block allows the rioter to set defaults, load resource locators and anything else you like.
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
				@acts ||= []
			end

			def event_processors
				@event_processors ||= []
			end

			def helper_mod
				@helper_mod ||= Module.new
			end
		end
	end
end
