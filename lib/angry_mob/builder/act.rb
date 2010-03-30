class AngryMob
  class Builder

    # A `Builder::Act` groups target calls.
    class Act
      include Log

      attr_reader :mob, :name, :definition_file

      def initialize(name,&blk)
        @name = name
        @blk = blk
      end

      # Binds the act to the mob and the file from which it came.
      def bind(mob,file)
        @mob  = mob
        @definition_file = file

        mob.acts[@name] = self
      end

      #### Compilation

      # Turn target definitions into `TargetCalls` recorded in the `TargetScheduler`
      def compile!
        instance_eval &@blk
      end

      # bundler + rubygems clusterfuck
      def gem(*args,&blk)
        __compile_target(:gem,*args,&blk)
      end

      def method_missing(nickname,*args,&blk)
        __compile_target(nickname,*args,&blk)
      end

      # Schedules a target, adding call-location context along the way.
      def __compile_target(nickname,*args,&blk)
        target = mob.scheduler.schedule_target(nickname, *args, &blk)

        # record call location information
        target.set_caller(caller(2).first) if target.respond_to?(:set_caller)
        target.act  = @name
        target.file = @definition_file

        target.merge_defaults(defaults.defaults_for(nickname)) if target.respond_to?(:merge_defaults)

        target
      end

      #### Definition helpers

      def defaults
        @defaults ||= Target::Defaults.new
      end

      def notify
        Target::Notify.new(@mob)
      end
      
      # directly schedule a call on the delayed list
      def later
        n = Target::Notify.new(@mob)
        @mob.scheduler.schedule_delayed_call n
        n
      end

      def node
        mob.node
      end

      def act_now *act_name
        act_name.norm!.each {|act_name| mob.compile_act(act_name)}
      end

      def schedule_act act_name
        mob.act_scheduler.schedule_act(act_name)
      end

    end
  end
end
