class AngryMob
  class Act
    class Predicate
      def self.build(*definitions,&blk)
        new(*definitions,&blk)
      end

      attr_reader :options
      def initialize(*definition,&blk)
        @options = AngryHash[ Hash === definition.last ? definition.pop : {} ]
        validate_options!
        parse!
      end

      def reset!
        @seen = nil
      end

      def validate_options!
        if ( passed = options.values_at(:on_any, :on, :on_all).compact ).size > 1
          raise "please specify only one of :on_all, :on or :on_any [you passed #{passed.inspect}]"
        end
      end

      def parse!
        if on = @options.delete(:on)
          @expression = on
        elsif on_all = @options.delete(:on_all)
          @expression = on_all.dup.unshift(:and)
        elsif on_any = @options.delete(:on_any)
          @expression = on_any.dup.unshift(:or)
        end
      end

      def match?(event)
        event = event.to_s
        seen!(event)
        match_expression?(event,@expression)
      end

      def match_expression?(event,expression)
        if Array === expression
          op,sub_expressions = expression[0], expression[1..-1]

          case op
          when :and
            sub_expressions.all? {|ex| match_expression?(event, ex)}
          when :or
            sub_expressions.any? {|ex| match_expression?(event, ex)}
          else
            raise "unknown operand #{op}"
          end
        else
          match_leaf?( event, expression )
        end
      end

      def match_leaf?(event,leaf)
        event == leaf.to_s || seen?(leaf)
      end

      def seen!(event)
        seen[event.to_s] = true
      end

      def seen
        @seen ||= {}
      end

      def seen?(event)
        seen[event.to_s]
      end
    end
  end
end
