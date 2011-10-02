class AngryMob
  class Act
    module Api

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
          rioter.target_mother.target(rioter, definition_file, nickname, *args, &blk).tap do |target|
            target.merge_defaults( defaults.defaults_for(nickname) )
            target.call
          end
        end
      end


      ########################
      #  Definition helpers  #
      ########################

      def defaults
        @defaults ||= Target::Defaults.new
      end


      def node
        rioter.node
      end


      def act_now act_name, *args
        rioter.act_scheduler.act_now act_name, {}, *args
      end


      def try_to_act_now act_name, *args
        rioter.act_scheduler.act_now act_name, {:try => true}, *args
      end


      def fire event_name
        rioter.act_scheduler.fire event_name
      end
    end
  end
end
