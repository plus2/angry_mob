require 'citrus'

class AngryMob
  class Act
    class Predicate
      def self.build(*definitions,&blk)
        new(*definitions,&blk)
      end

      def self.parser
        @parser ||= Citrus.load( File.expand_path('../predicate', __FILE__) ).first
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
        ruby_string = Predicate.parser.parse(@options.delete(:on)).to_ruby
        self.class.class_eval "def match_predicate?(new_event)\n#{ruby_string}\nend".tapp
      rescue Citrus::ParseError
        $!.consumed.tapp(:c)
        raise $!
      end

      def match?(event)
        event = event.to_s
        seen!(event)
        match_predicate?(event)
      end

      def match_event?(new_event,event)
        new_event == event.to_s || seen?(event)
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
