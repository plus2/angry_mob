class AngryMob
	class Target
		class Call # TODO  < Blankslate
			attr_accessor :act, :file, :action_names

			def initialize(target, action_names)
				@target = target
				@action_names = action_names
			end

			def call(node)
				@target.call(node,self)
			end

      def clear_actions!
        @action_names = []
      end

			attr_reader :defined_at
			def set_caller(c)
				@defined_at = c[/^([^:]+:\d+):/,1]
			end

			def merge_defaults(defaults)
				@target.merge_defaults(defaults)
			end

			def inspect
				"#<TC:#{@target.nickname} obj=#{@target.default_object} actions=#{@action_names.inspect} defined_at=#{@defined_at}>"
			end

			def method_missing(method,*args,&blk)
				@target.send method, *args, &blk
			end
		end
	end
end
