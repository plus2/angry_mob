class AngryMob
	class ActScheduler
    include Log

    attr_writer :node
    attr_reader :acted

    def initialize
      reset!
    end

    def reset!
      @act_names = nil
      @acted = []
    end

    def act_names
      @act_names ||= @node.acts || []
    end

    def acts
      @acts ||= Dictionary.new
    end

    def add_act(name,act)
      acts[name.to_s] = act
    end

    def run!
      each_act {|act| act_now(act)}
    end

		def each_act
      while act_name = next_act
        act = acts[act_name] || raise(AngryMob::MobError,"no act named '#{act_name}'")
				yield act
      end
		end

    def start_iterating!
      unless @iterating
        @iterating_act_names = act_names.dup
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

    def act_now(act)
      unless AngryMob::Builder::Act === act
        act = acts[act]
      end

      raise(AngryMob::MobError, "no act named '#{act}'") unless act

      name = act.name.to_s

      if acted.include?(name)
        log "(not re-running act #{name} - already run)"
        return
      end

      acted << name

      log "running act #{name}"
      act.run!
    end
	end
end
