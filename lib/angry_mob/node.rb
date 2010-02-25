
class AngryMob
  class Node < Struct.new(:name,:attributes)
    include Log

    def initialize(name, attributes)
      self.name = name
      self.attributes = Hashie::Mash.new(attributes)
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
        @iterating_act_names = act_names.dup
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

        log

        begin
          target.call(self)
        rescue Object
          log "error calling #{target} defined_at=#{target.defined_at.inspect if target.respond_to?(:defined_at)}"
          raise $!
        end
      end

      delayed_targets.each {|t| t.call(self)}
    end

    def notify(notification)
      if AngryMob::NotifyBuilder === notification
        # TODO
        log "notify builder"
      else
        later = [ notification[:later] ].flatten.compact
        now   = [ notification[:now  ] ].flatten.compact

        now.each {|n| n.call(node)}

        delayed_targets += later
      end
    end

    def merge_defaults(attrs)
      attributes.replace( Hashie::Mash.new(attrs).update(attributes) )
    end

    def schedule_act(*acts)
      raise(CompilationError, "schedule_act called when not compiling") unless @iterating
      @iterating_act_names += acts
    end

    def method_missing(method,*args,&block)
      attributes.send(method,*args)
    end
  end
end
