class AngryMob
  class Builder

    class Act
      include Log

      attr_reader :mob

      def initialize(name,&blk)
        @name = name
        @blk = blk
      end

      def bind(mob,file)
        @mob  = mob
        @file = file

        mob.acts[@name] = self
      end

      def compile!
        instance_exec node, &@blk
      end

      def defaults
        @defaults ||= Target::Defaults.new
      end

      def notify
        Target::Notify.new(@mob)
      end
      
      # directly schedule a call on the delayed list
      def later
        returning(Target::Notify.new(@mob)) do |n|
          @mob.scheduler.schedule_delayed_call n
        end
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

      if instance_methods.include? :gem
        undef :gem
      end

      def method_missing(nickname,*args,&blk)
        target = mob.scheduler.schedule_target(nickname, *args, &blk)

        # record call location information
        target.set_caller(caller(1).first) if target.respond_to?(:set_caller)
        target.act  = @name
        target.file = @file

        target.merge_defaults(defaults.defaults_for(nickname)) if target.respond_to?(:merge_defaults)

        target
      end
    end
  end
end
