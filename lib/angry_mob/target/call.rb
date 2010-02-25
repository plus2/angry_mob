class AngryMob
	class Target
		class Call # TODO  < Blankslate
			attr_accessor :act
			attr_reader :action_names

			def initialize(target, action_names)
				@target = target
				@action_names = action_names
			end

			def call(node)
				@target.call(node,self)
			end

			def defined_at
				@defined_at ||= []
			end
			
			def add_caller(c)
				defined_at << c
			end

			def merge_defaults(defaults)
				@target.merge_defaults(defaults)
			end

			def inspect
				"#<TC:#{@target.nickname} obj=#{@target.default_object} actions=#{@action_names.inspect}>"
			end

			def method_missing(method,*args,&blk)
				@target.send method, *args, &blk
				self
			end
		end
	end
end
