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
      def __run_target(nickname,*args)
        call = mob.target_mother.target_call(nickname,*args)

        call.merge_defaults(defaults.defaults_for(nickname))
        call.call(self)

        call.target
      end

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
        mob.target_scheduler.schedule_delayed_call n
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
