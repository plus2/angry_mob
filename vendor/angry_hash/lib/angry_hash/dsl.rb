class AngryHash
  module DSL
    # from ActiveSupport 3
    if defined? ::BasicObject
      # A class with no predefined methods that behaves similarly to Builder's
      # BlankSlate. Used for proxy classes.
      class BasicObject < ::BasicObject
        undef_method :==
        undef_method :equal?

        # Let BasicObject at least raise exceptions.
        def raise(*args)
          ::Object.send(:raise, *args)
        end
      end
    else
      class BasicObject #:nodoc:
        instance_methods.each do |m|
          undef_method(m) if m.to_s !~ /(?:^__|^nil\?$|^send$|^object_id$|^instance_eval$)/
        end
      end
    end

    class Env < BasicObject
      def __store
        @store ||= {}
      end
      def method_missing(method,*args,&blk)
        method_s = method.to_s
        if method_s[/[A-Za-z0-9]$/] && args.size == 1
          __store[method.to_s] = args.first
        else
          super
        end
      end
    end

    def __eval_as_dsl(&blk)
      env = Env.new
      env.instance_eval(&blk)
      deep_update(env.__store)
    end
  end
end
