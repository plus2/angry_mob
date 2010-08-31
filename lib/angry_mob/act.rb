class AngryMob
  # A `Builder::Act` groups target calls.
  class Act
    autoload :Scheduler     , "angry_mob/act/scheduler"
    autoload :Predicate     , "angry_mob/act/predicate"
    autoload :EventProcessor, "angry_mob/act/event_processor"

    attr_reader :mob, :rioter, :name, :definition_file, :options, :predicate

    NullMobInstance = NullMob.new

    def initialize(mob,*args,&blk)
      @mob     = mob
      @options = args.extract_options!
      @name    = args.shift || generate_random_name

      @multi   = !! options.delete(:multi)
      @blk     = blk

      parse_predicate!
    end

    def parse_predicate!
      begin
        @predicate = Predicate.build( options.slice(:on,:on_all,:on_any) )
      rescue Citrus::ParseError
        puts "error creating predicate on act #{name} #{options[:definition_file]}"
        raise $!
      end
    end

    def ui; mob.ui end
    def log(message); mob.ui.log message end

    def multi?; !!@multi end

    def match?(event)
      @predicate.match?(event)
    end

    # Binds the act to the rioter and the file from which it came.
    def bind(rioter,file)
      @rioter          = rioter
      @definition_file = file

      rioter.act_scheduler.add_act @name, self
    end

    #### Compilation

    # Executes the block via `instance_exec`
    def run!(*arguments)
      ui.push("act '#{name}'", :bubble => true) do
        @running = true

        instance_exec *arguments, &@blk

        @running = false
      end
    end

    # bundler + rubygems clusterfuck
    def gem(*args,&blk)
      __run_target(:gem,*args,&blk)
    end

    # TODO - de-mm
    def method_missing(nickname,*args,&blk)
      return super unless @running
      __run_target(nickname,*args,&blk)
    end

    # Schedules a target, adding call-location context along the way.
    def __run_target(nickname,*args,&blk)
      call = rioter.target_mother.target_call(nickname,*args,&blk)

      call.merge_defaults(defaults.defaults_for(nickname))
      call.call(self)

      call.target
    end

    def in_sub_act(*args,&blk)
      sub_act = self.class.new(NullMobInstance, "sub-act-#{name}", {:multi => true}, &blk)
      sub_act.bind(rioter,@definition_file)
      sub_act.run!(*args)
    end

    #### Definition helpers

    def defaults
      @defaults ||= Target::Defaults.new
    end

    def node
      rioter.node
    end

    def act_now act_name, *args
      rioter.act_scheduler.act_now act_name, *args
    end

    def fire event_name
      rioter.act_scheduler.fire event_name
    end

    def schedule_act act_name
      raise "to remove"
    end

    protected
    def generate_random_name
      if definition_file
        "act-#{Util.snake_case(definition_file.split('/').last)}-#{SecureRandom.hex(10)}"
      else
        "act-#{SecureRandom.hex(10)}"
      end
    end
  end
end
