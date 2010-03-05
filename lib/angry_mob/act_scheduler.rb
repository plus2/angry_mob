class AngryMob
	class ActScheduler < Struct.new(:node)
    def act_names
      @act_names ||= node.acts || []
    end

		def each_act
      while act_name = next_act
				yield act_name
      end
		end

    def start_iterating!
      unless @iterating
        @iterating_act_names = act_names.dup.tapp
        @iterating = true
      end
    end

    def next_act
      start_iterating!
      @iterating_act_names.shift
    end

    def schedule_act(*acts)
      raise(CompilationError, "schedule_act called when not compiling") unless @iterating
      @iterating_act_names += acts
    end
	end
end
