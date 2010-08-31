class AngryMob
  class Act
    class EventProcessor
      attr_reader :options

      def initialize(*args,&blk)
        @options = Hash === args.first ? args.pop : {}
        @args    = args
        @block   = blk
      end

      def bind(rioter)
        @rioter = rioter
        rioter.act_scheduler.event_processors << self
      end

      def call(queue)
        if (event_names = options[:mutex]) && ! event_names.empty?
          seen = Hash.new {|h,k| h[k] = []}
          last_index = nil

          queue.each_with_index {|e,i| 
            if event_names.include?(e)
              seen[e] << i
              last_index = i
            end
          }

          dominant_event = event_names.find {|e| !seen[e].empty? }

          new_queue = []
          queue.each_with_index {|e,i|
            if seen[e].include?(i)
              if i == last_index
                new_queue << e
              else
                new_queue << nil
              end
            else
              new_queue << e
            end
          }

          queue.replace( new_queue.compact )
        end
      end
    end
  end
end
