class AngryMob
  # The `TargetScheduler` is how the targets are actually run.
  # This includes targets, delayed targets and notifications.

	class TargetScheduler < Struct.new(:mob)
		include Log

    # The list of delayed targets.
    def delayed_targets
      @delayed_targets ||= []
    end

    # Iterates through the targets, then the delayed targets.
    def run!
      running_targets = delayed_targets.reverse
      
      log "running #{running_targets.size} delayed targets"

      #AngryMob::Builder::Act.synthesise(mob,'delayed_targets') do
        while target = running_targets.pop
          begin
            target.call(mob)
          rescue Object
            log "error [#{$!.class}] #{$!}\ncalling #{target.inspect[0..200]}"
            raise $!
          end
        end
      #end
    end

    # Resolve delayed targets to TargetCalls, as they can be recorded in various ways.
    # TODO - every target call-like should have a .to_target_call, for quacking
		def process_delayed_targets
			delayed_targets.map! do |target|
				case target
				when AngryMob::Target::Notify
					target.target_call
				else
					target
				end
			end

      # TODO - squeeze repeated targets
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
