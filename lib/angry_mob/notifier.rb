class AngryMob
  class NotificationInspector
    attr_reader :nickname, :options
    def initialize(scheduler,nickname,options={},&block)
      @scheduler,@nickname,@options = scheduler,nickname.to_s,options

      unless notifications.empty?
        yield_in_context(self,&block)
      end
    end

    def yield_in_context(*args,&block)
      if o = options[:context]
        o.instance_exec(*args,&block)
      else
        block.call(*args)
      end
    end

    def notifications
      @notifications ||= @scheduler.notifications.select {|n| n.target == nickname}
    end

    def action?(*actions)
      actions.norm!.all? {|action| notifications.any? {|n| n.actions.include?(action.to_s)}}
    end

    def select_and_run_action(actions, &block)
      if matched = actions.find {|action| action?(action)}
        yield_in_context matched, &block
      end
    end
  end

  class Notifier < Struct.new(:mob)
    def ui; mob.ui end

    # The list of delayed targets.
    def notifications
      @notifications ||= []
    end

    def for(nickname,options={},&block)
      NotificationInspector.new(self,nickname,options,&block)
    end

    def select(&block); notifications.select(&block) end
    def find(&block); notifications.find(&block) end
    def any?(&block); notifications.any?(&block) end
    def all?(&block); notifications.all?(&block) end

    # queries
    def include_nickname?(nickname)
      nickname = nickname.to_s
      notifications.any? {|n| n.target == nickname}
    end

    def __predicate_to_lambda()
      args = Target::Arguments.parse(*args)
    end

    # Handles a notification, by either placing it on the queue or calling it now
    def notify(notification)
      if AngryMob::Target::Notify === notification
        notifications << notification
      elsif Proc === notification
        notification[mob]
      end
    end

    def schedule_notification(call)
      notifications << call
    end

  end
end
