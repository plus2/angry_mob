class AngryMob
  # A `Builder::Act` groups target calls.
  class Act
    autoload :Scheduler, "angry_mob/act/scheduler"
    autoload :Predicate, "angry_mob/act/predicate"

    attr_reader :mob, :name, :definition_file

    def initialize(name,options={},&blk)
      @name    = name.to_s
      @options = options
      @multi   = !! options.delete(:multi)
      @blk     = blk
      @predicate = Predicate.build( options.slice(:on,:on_all) )
    end

    def ui; mob.ui end
    def log(message); mob.ui.log message end

    def multi?; !!@multi end

    def match?(event)
      @predicate.match?(event)
    end

    # Binds the act to the mob and the file from which it came.
    def bind(mob,file)
      @mob  = mob
      @definition_file = file

      mob.act_scheduler.add_act @name, self
    end

    # XXX is this used?
    def self.synthesise(mob,name,&blk)
      act = new(name,true,&blk)
      act.bind(mob,"name")
      act.run!
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
      call = mob.target_mother.target_call(nickname,*args,&blk)

      call.merge_defaults(defaults.defaults_for(nickname))
      call.call(self)

      call.target
    end

    def in_sub_act(*args,&blk)
      sub_act = self.class.new("#{name}-sub-act", {:multi => true}, &blk)
      sub_act.bind(@mob,@definition_file)
      sub_act.run!(*args)
    end

    #### Definition helpers

    def defaults
      @defaults ||= Target::Defaults.new
    end

    def notify
      Target::Notify.new(self)
    end

    def notifications
      mob.notifier
    end
    
    # directly schedule a call on the delayed list
    def later
      n = Target::Notify.new(self)
      mob.notifier.schedule_notification n
      n
    end

    def node
      mob.node
    end

    def act_now act_name, *args
      mob.act_scheduler.act_now(act_name,*args)
    end

    def schedule_act act_name
      mob.act_scheduler.schedule_act(act_name)
    end

    def schedule_acts_matching(regex,&block)
      mob.act_scheduler.schedule_acts_matching(regex,&block)
    end

  end
end
