class AngryMob
  class Builder

    # A `Builder::Act` groups target calls.
    class Act

      attr_reader :mob, :name, :definition_file

      def initialize(name,&blk)
        @name = name
        @blk = blk
      end

      def ui; mob.ui end
      def log(message); mob.ui.log message end

      # Binds the act to the mob and the file from which it came.
      def bind(mob,file)
        @mob  = mob
        @definition_file = file

        mob.act_scheduler.add_act @name, self
      end

      def self.synthesise(mob,name,&blk)
        act = new(name,&blk)
        act.bind(mob,"name")
        act.run!
      end

      #### Compilation

      # Executes the block via `instance_eval`
      def run!
        ui.push("act '#{name}'", :bubble => true) do
          @running = true

          instance_eval &@blk

          __finalise_current_target

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

        __finalise_current_target

        @current_target = target = mob.target_registry.target(nickname,*args,&blk)

        target.setup_for_call!(self)                           if target.respond_to?(:setup_for_call!)
        target.merge_defaults(defaults.defaults_for(nickname)) if target.respond_to?(:merge_defaults)

        target
      end

      def __finalise_current_target
        if @current_target && @current_target.respond_to?(:finalise_call!)
          @current_target.finalise_call!
        end
      end
      alias_method :finalise!, :__finalise_current_target

      def in_sub_act(&blk)
        sub_act = self.class.new("#{name}-sub-act",&blk)
        sub_act.bind(@mob,@definition_file)
        sub_act.run!
      end

      #### Definition helpers

      def defaults
        @defaults ||= Target::Defaults.new
      end

      def notify
        Target::Notify.new(self)
      end
      
      # directly schedule a call on the delayed list
      def later
        n = Target::Notify.new(self)
        mob.scheduler.schedule_delayed_call n
        n
      end

      def node
        mob.node
      end

      def act_now *act_name
        act_name.norm.each {|act_name| mob.act_scheduler.act_now(act_name)}
      end

      def schedule_act act_name
        mob.act_scheduler.schedule_act(act_name)
      end

    end
  end
end
