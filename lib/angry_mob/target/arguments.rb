class AngryMob
  class Target
    class Arguments
      attr_reader :args, :actions

      def initialize(*args,&blk)
        @args = extract_args(args,&blk)
        extract_actions!
      end

      def self.parse(input,&blk)
        case input
        when Arguments
          input
        when Array
          if input.size == 1 && Arguments === input.first
            input.first
          else
            self.new(input,&blk)
          end
        else
          self.new(input,&blk)
        end
      end

      # update args without updating actions too
      def update_preserving_actions(other_args)
        other_args = self.class.parse(other_args)
        @args.deep_update(other_args.args)
        self
      end

      def method_missing(meth,*args,&block)
        @args.send(meth,*args,&block)
      end

      def extract_actions!
        @actions = [ @args.delete('actions'), @args.delete('action') ].norm.map {|s| s.to_s}
      end
      def actions=(array)
        @actions = array.norm.map{|s| s.to_s}
      end

      def extract_args(args,&blk)
        args.flatten!

        case args.size
        when 0,1
          if Hash === args[0]
            new_args = AngryHash.__convert_without_dup(args[0])
            new_args.default_object = new_args
          else
            new_args = AngryHash.new
            new_args.default_object = args[0]
          end

        when 2
          new_args = AngryHash.__convert_without_dup(args[1])
          new_args.default_object = args[0]

        else
          raise ArgumentError, "usage: nickname(default_object, [ :optional_hash_of => opts ])"
        end

        new_args
      end
    end
  end
end
