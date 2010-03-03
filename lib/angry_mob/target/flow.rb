class AngryMob
  class Target
    class Flow < BlankSlate
      def initialize(*args,&blk)
        @options = args.extract_options!
        @targets = []

        @defining = true
        yield self
        @defining = false
      end

      def __mob ; @options[:mob ] end
      def __node; @options[:node] end

      def method_missing(nickname,*args,&blk)
        return super unless @defining

        opts = args.options

        this          = self
        index         = @targets.size
        original_opts = opts.dup
        
        opts.update(:notify => lambda {|node| this.__notified(node, index)})

        unless @targets.empty?
          opts.update(:action => :nothing)
        end

        target = __node.schedule_target(__mob,nickname,*args)
        @targets << [target, original_opts]

        target
      end

      def __notified(node,index)
        target,opts = *@targets[index+1]

        if target
          target.action_names = opts.action
        end
      end
    end
  end
end
