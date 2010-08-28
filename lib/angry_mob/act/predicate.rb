require 'citrus'

class AngryMob
  class Act
    class NoPredicate
      def match?(*); false end
      def on; "false" end
    end

    class YesPredicate
      def match?(*); true end
      def on; "true" end
    end

    class Predicate
      def self.build(*definition,&blk)
        options = Hash === definition.last ? definition.last : {}

        if on = options[:on]
          on_string = on.to_s
        elsif on_all = options[:on_all]
          if on_all.empty?
            return NoPredicate.new
          else
            on_string = on_all.join(' && ')
          end
        elsif on_any = options[ :on_any ]
          if on_any.empty?
            return NoPredicate.new
          else
            on_string = on_any.join(' || ')
          end
        end

        if on_string
          new(on_string,options,&blk)
        else
          NoPredicate.new
        end
      end

      def self.parser
        @parser ||= Citrus.load( File.expand_path('../predicate', __FILE__) ).first
      end

      attr_reader :options, :on
      def initialize(on,options,&blk)
        @on = on
        @options = AngryHash[ options ]
        parse!
      end

      def reset!
        @seen = nil
      end

      def parse!
        ruby_string = Predicate.parser.parse(@on).to_ruby
        instance_eval "@predicate = lambda {|new_event| #{ruby_string} }"
      rescue Citrus::ParseError
        puts "exception [#{$!.class}] parsing: expression=#{on}\nconsumed=#{$!.consumed}"
        raise $!
      rescue
        puts "exception [#{$!.class}] parsing: expression=#{on} #{@options.inspect}"
        raise $!
      end

      def match?(event)
        event = event.to_s
        seen!(event)
        @predicate[event]
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
