
class AngryMob
  class Node < Struct.new(:name,:attributes,:resource_locator)
    include Log

    def initialize(name, attributes)
      self.name = name
      self.attributes = AngryHash[attributes]
    end

    def targets
      @targets ||= []
    end

    def delayed_targets
      @delayed_targets ||= []
    end

    def act_names
      @act_names ||= attributes[:acts] || []
    end

    def start_iterating!
      unless @iterating
        @iterating_act_names = act_names.dup.tapp
        @iterating = true
      end
    end

    def next_act
      start_iterating!
      @iterating_act_names.shift
    end

    def run!
      @running_targets = targets.reverse
      
      log "running #{@running_targets.size} targets"

      while target = @running_targets.pop

        log # blank line

        begin
          target.call(self)
        rescue Object
          log "error [#{$!.class}] #{$!}\ncalling #{target.inspect}"
          raise $!
        end
      end

      log "running #{delayed_targets.size} delayed targets"
      # TODO - uniq these
      delayed_targets.each {|t| t.call(self)}
    end


    # handles a notification, by either placing it on the queue or calling it now
    def notify(notification)
      if AngryMob::Target::Notify === notification
        if notification.later?
          delayed_targets << notification.target_call
        else
          notification.target_call.call(self)
        end
      elsif Proc === notification
        notification[self]
      end
    end

    def merge_defaults(attrs)
      attributes.reverse_deep_update!(attrs)
    end

    def schedule_act(*acts)
      raise(CompilationError, "schedule_act called when not compiling") unless @iterating
      @iterating_act_names += acts
    end

    def schedule_target(mob,nickname,*args)
      targets << target = mob.target(nickname,*args)
      target
    end

    def method_missing(method,*args,&block)
      attributes.__send__(method,*args)
    end
  end
end
