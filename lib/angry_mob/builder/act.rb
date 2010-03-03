class AngryMob
  class Builder

    class Act
      def initialize(name,&blk)
        @name = name
        @blk = blk
      end

      def bind(mob,file)
        @mob = mob
        @file = file
        mob.acts[@name] = self
      end

      def compile!(node)
        @node = node
        instance_exec node, &@blk
      end

      def defaults
        @defaults ||= Target::Defaults.new
      end

      def notify
        Target::Notify.new(@mob,@node)
      end

      def flow(*args,&blk)
        args.options.update :mob => @mob, :node => @node, :act => self
        Target::Flow.new *args, &blk
      end

      def node
        @node
      end

      def act_now *act_name
        act_name.flatten!
        act_name.compact!
        # XXX - only allow once
        act_name.each {|act_name| @mob.compile_act(@node, act_name)}
      end

      def schedule_act act_name
        node.schedule_act(act_name)
      end

      if instance_methods.include? :gem
        undef :gem
      end

      def method_missing(nickname,*args,&blk)
        target = @node.schedule_target(@mob, nickname, *args)

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
