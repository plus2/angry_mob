class AngryMob
  class Target
    class Flow
      def initialize
        @targets = []
      end

      def <<(call)
        @targets << [call, call.args.dup]

        this  = self
        index = @targets.size-1

        call.args.update(:notify => lambda {|node| this.notified(node, index)})

        unless @targets.size == 1
          call.action_names = [:nothing]
        end

        call
      end

      def notified(node,index)
        target,opts = *@targets[index+1]

        if target
          target.action_names = opts.action
        end
      end
    end
  end
end
