class AngryMob
  class Target
    class Call
      attr_reader :args, :klass, :actions
      attr_accessor :target

      def initialize(klass,*args)
        @klass = klass
        @args = extract_args(args)
        validate_actions!
      end

      def instance_key
        klass.instance_key(args)
      end

      def merge_defaults(defaults)
        args.reverse_deep_merge!(defaults)
      end

      def call(act)
        target.act = act
        target.noticing_changes(args) {
          actions.each {|action|
            target.send(action)
          }
        }
      end

      def nickname
        klass.nickname
      end

      def validate_actions!
        @actions = [ args.actions, args.action ].norm.map{|s| s.to_s}

        #klass.tapp
        #actions.tapp('requested actions')
        #klass.default_action_name.tapp('default action')

        extras = actions - klass.all_actions
        raise(ArgumentError, "#{nickname}() unknown actions #{extras.inspect}") unless extras.empty? || extras == ['nothing']

        actions << klass.default_action_name if actions.empty?

        if actions.norm.empty?
          raise ArgumentError, "#{klass.nickname}() no actions selected, and no default action defined"
        end

        actions.tapp('selected action')
      end


      def extract_args(args)
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
          raise ArgumentError, "usage: #{klass.nickname}(default_object, [ :optional_hash_of => opts ])"
        end

        new_args
      end
    end
  end
end
