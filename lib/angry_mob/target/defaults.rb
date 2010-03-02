class AngryMob
  class Target
    class Defaults
      def initialize
        @contexts = Hash.new {|h,k| h[k] = []}
      end

      def defaults_for(name)
        @contexts[name].last || {}
        # TODO -> merge under some circumstances
      end

      def method_missing(method, *args, &blk)
        @contexts[method] << args.first

        if block_given?
          yield
          @contexts[method].pop
        end
      end
    end
  end
end
