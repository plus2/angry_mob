
class AngryMob
  class Node < Struct.new(:name,:attributes)
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
      @iterating_act_names.pop
    end

    def notify(notification)
      later = [ notification[:later] ].flatten.compact
      now   = [ notification[:now  ] ].flatten.compact

      now.each {|n| n.call(node)}

      delayed_targets += later
    end

    def merge_defaults(attrs)
      attributes.replace( Hashie::Mash.new(attrs).update(attributes) )
    end

    def schedule_act(*acts)
      acts.tapp
      # TODO implement
    end

    def method_missing(method,*args,&block)
      attributes.send(method,*args)
    end
  end
end
