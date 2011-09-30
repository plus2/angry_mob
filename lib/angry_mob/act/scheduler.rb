class AngryMob
  class Act

    # The `AngryMob::Act::Scheduler` is responsible for executing acts.
    #
    # The order of act execution is based on
    # - matching acts against events
    # - direct execution of acts using `act_now`
    class Scheduler
      attr_writer :node
      attr_reader :acted, :rioter, :event_processors


      def initialize(rioter)
        @rioter = rioter
        @event_queue = []
        @event_processors = []
        reset!
      end


      def run!
        # fire initial events
        seed_events.each do |event|
          fire event
        end

        # schedule events until the event queue is empty
        exhaust_queue

        # finalisation phase: fire the finalise event and exhaust the queue again
        fire 'finalise'
        exhaust_queue

        ui.good "finished running acts"
      end


      # API
      def act_now(act_name, options, *arguments)
        act, act_name = *resolve_act( act_name, options, *arguments )


        unless act
          act_missing!(act_name, options)
          return
        end


        if !act.multi? && acted.include?(act_name)
          ui.skipped! "(not re-running act #{act_name} - already run)"
          return
        end


        acted!(act_name)


        act.run!(*arguments)
        fire( "finished/#{act.name}" )
      end


      # API
      def fire(event)
        ui.sigil '->', event, :green
        @event_queue.unshift event

        # process the eq
        @event_processors.each {|ep| ep.call(@event_queue)}
      end


      def exhaust_queue
        while event = @event_queue.pop do
          ui.sigil '<-', event, :green

          acts = available_acts.values.select {|act| act.match?(event)}

          acts.map {|a| a.name}

          acts.each do |act|
            next if acted?(act)
            acted!(act)

            act.run!
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


      # based on available info, resolve the act and its name
      def resolve_act( act_or_name, options, *arguments )
        if AngryMob::Act === act_or_name
          act      = act_or_name
          act_name = act.name

        elsif act_or_name < AngryMob::Actor
          act      = act_or_name.build_instance( options, *arguments )
          act_name = act.name

        else
          act_name = act_or_name
          act      = acts[act_name]
        end

        [ act, act_name ].tapp
      end


      def add_act(name,act)
        acts[name.to_s]           = act
        available_acts[name.to_s] = act
      end


      def ui; @rioter.ui end


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
        !( FalseClass === rioter.node.raise_on_missing_act )
      end


      def act_missing!(name, options)
        if !options[:try] && raise_on_missing_act?
          raise(AngryMob::MobError, "no act named '#{name}'") 
        end
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
