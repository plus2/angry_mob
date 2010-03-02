class AngryMob
  class Builder
    autoload :Defaults, "angry_mob/builder/defaults"
    autoload :Notify  , "angry_mob/builder/notify"

    class Act
      def initialize(name,&blk)
        @name = name
        @blk = blk
      end

      def bind(mob)
        @mob = mob
        mob.acts[@name] = self
      end

      def compile!(node)
        @node = node
        instance_exec node, &@blk
      end

      def defaults
        @defaults ||= Defaults.new
      end

      def notify
        Notify.new(@mob,@node)
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

      def method_missing(method,*args,&blk)
        @node.targets << t = @mob.target(method,*args,&blk)

        t.set_caller(caller(1).first) if t.respond_to?(:set_caller)
        t.act = @name

        t.merge_defaults(defaults.defaults_for(method)) if t.respond_to?(:merge_defaults)

        t
      end
    end
  end
end
