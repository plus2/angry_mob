class AngryMob
  # The `Target::Scheduler` is how targets delayed via notification are actually run.

  class Target
    class Scheduler < Struct.new(:mob)
      def ui; mob.ui end

      # The list of delayed targets.
      def notifications
        @notifications ||= []
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
end
