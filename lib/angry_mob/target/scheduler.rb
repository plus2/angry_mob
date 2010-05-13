class AngryMob
  # The `Target::Scheduler` is how targets delayed via notification are actually run.

  class Target
    class Scheduler < Struct.new(:mob)
      def ui; mob.ui end

      # The list of delayed targets.
      def delayed_targets
        @delayed_targets ||= []
      end

      # Iterates through the targets, then the delayed targets.
      def run!
        running_targets = delayed_targets.reverse
        
        ui.log "running #{running_targets.size} delayed targets"

        #AngryMob::Builder::Act.synthesise(mob,'delayed_targets') do
          while target = running_targets.pop
            begin
              target.call(mob)
            rescue Object
              ui.error "error [#{$!.class}] #{$!}\ncalling #{target.inspect[0..200]}"
              raise $!
            end
          end
        #end
      end

      # Handles a notification, by either placing it on the queue or calling it now
      # TODO this needs a-fixin'
      def notify(notification)
        if AngryMob::Target::Notify === notification
          if notification.later?
            delayed_targets << notification
          else
            notification.call
          end
        elsif Proc === notification
          notification[mob]
        end
      end

      def schedule_delayed_call(call)
        delayed_targets << call
      end

    end
  end
end
