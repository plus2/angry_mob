class AngryMob
  class Act
    module Api

			def self.included(base)
				base.class_eval do
					attr_reader :node, :act_scheduler
				end
			end
				

      def self.running(flag=true)
        original_running,@running = @running,flag
        yield
      ensure
        @running = original_running
      end


      def self.running?
        !! @running
      end


      ##############
      #  Dispatch  #
      ##############

      def method_missing(nickname, *args, &blk)
        return super unless AngryMob::Act::Api.running?
        __run_target(nickname, *args, &blk)
      end


      # bundler + rubygems clusterfuck
      def gem(*args,&blk)
        __run_target(:gem, *args, &blk)
      end


      # Locates and calls a `Target::Call` (which wraps a `Target`).
      # The wrapped `Target` is returned.
      def __run_target(nickname, *args, &blk)
        AngryMob::Act::Api.running(false) do
          target(self, nickname, *args, &blk).tap do |target|
            target.merge_defaults( defaults.defaults_for(nickname) )
            target.call
          end
        end
      end


			# Map nickname -> class, instantiate
      def target(act, nickname, *args, &blk)
				target_classes = Target::Tracking.subclasses
        target_class = target_classes[nickname.to_s]

        raise(MobError, "no target nicknamed '#{nickname}'\navailable targets:\n#{target_classes.keys.inspect}") unless target_class

        target_class.new( act, args, &blk )
      end



      ########################
      #  Definition helpers  #
      ########################

      def defaults
        @defaults ||= Target::Defaults.new
      end


      def act_now act_name, *args
        act_scheduler.act_now act_name, {}, *args
      end


      def try_to_act_now act_name, *args
        act_scheduler.act_now act_name, {:try => true}, *args
      end


      def fire event_name
        act_scheduler.fire event_name
      end
    end
  end
end
