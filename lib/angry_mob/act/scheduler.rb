class AngryMob
  class Act
    class Scheduler
      attr_writer :node
      attr_reader :acted, :mob

      def initialize(mob)
        @mob = mob
        @event_queue = []
        reset!
      end

      def run!
        ui.task "available acts #{available_acts.keys.inspect}"

        seed_events.each do |event|
          fire event
        end

        exhaust_queue

        ui.good "finished running acts"

        # finalise_acts!
      end

      def act_now(act_name,*arguments)
        if AngryMob::Act === act_name
          act = act_name
          act_name = act.name
        else
          act = acts[act_name]
        end

        unless act
          act_missing!(act_name) 
          return
        end

        if !act.multi? && acted.include?(act_name)
          ui.skipped! "(not re-running act #{act_name} - already run)"
          return
        end

        acted!(act_name)

        act.run!(*arguments)
      end

      def fire(event)
        ui.task "firing '#{event}'"
        @event_queue.unshift event
      end

      def exhaust_queue
        while event = @event_queue.pop do
          ui.log "popped event #{event}"

          acts = available_acts.values.select {|act| act.match?(event)}

          acts.each do |act|
            next if acted?(act)
            acted!(act)

            act.run!
            fire( "finished/#{act.name}" )
          end
        end

        ui.log "events done"
      end

      def acted!(act_or_name)
        name = act_name(act_or_name)

        available_acts.delete(name)
        acted_acts[ name ]
        acted << name
      end

      def acted?(act_or_name)
        acted_acts.key?( act_name(act_or_name) )
      end


      ## Utilities

      def add_act(name,act)
        acts[name.to_s]           = act
        available_acts[name.to_s] = act
      end

      def ui; @mob.ui end

      def reset!
        %w{ seed_events available_acts acted_acts }.each {|ivar| instance_variable_set("@#{ivar}", nil)}
        @acted = []
      end
      
      def seed_events
        @seed_events ||= ( @node.fire || [] ).map {|e| e.to_s}
      end

      def acts
        @acts ||= Dictionary.new
      end

      def available_acts
        @available_acts ||= {}
      end

      def acted_acts
        @acted_acts ||= {}
      end

      def raise_on_missing_act?
        !( FalseClass === mob.node.raise_on_missing_act )
      end

      def act_missing!(name)
        raise(AngryMob::MobError, "no act named '#{name}'") if raise_on_missing_act?
      end

      def act_name(act_or_name)
        name = if AngryMob::Act === act_or_name
          act_or_name.name
        else
          act_or_name
        end

        name.to_s
      end

    end
  end
end
